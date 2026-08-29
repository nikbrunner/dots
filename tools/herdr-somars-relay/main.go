package main

import (
	"bufio"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

type inputFilter struct {
	pendingEscape bool
}

func (f *inputFilter) Feed(data []byte) ([]byte, bool) {
	forwarded := make([]byte, 0, len(data))
	toggled := false

	for _, byte := range data {
		if f.pendingEscape {
			f.pendingEscape = false
			if byte == 'r' {
				toggled = true
				continue
			}
			forwarded = append(forwarded, 0x1b)
		}

		if byte == 0x1b {
			f.pendingEscape = true
		} else {
			forwarded = append(forwarded, byte)
		}
	}

	return forwarded, toggled
}

func (f *inputFilter) Flush() []byte {
	if !f.pendingEscape {
		return nil
	}
	f.pendingEscape = false
	return []byte{0x1b}
}

type controlMessage struct {
	Type  string `json:"type"`
	Bytes string `json:"bytes"`
}

type terminalInput struct {
	Type       string `json:"type"`
	DataBase64 string `json:"data_base64"`
}

type socketRequest struct {
	ID     string         `json:"id"`
	Method string         `json:"method"`
	Params map[string]any `json:"params"`
}

func sendControl(writer io.Writer, message any) error {
	data, err := json.Marshal(message)
	if err != nil {
		return err
	}
	_, err = fmt.Fprintf(writer, "%s\n", data)
	return err
}

func sendInput(writer io.Writer, data []byte) error {
	return sendControl(writer, terminalInput{
		Type:       "terminal.input",
		DataBase64: base64.StdEncoding.EncodeToString(data),
	})
}

func readFrames(reader io.Reader, output io.Writer, done chan<- error) {
	input := bufio.NewReader(reader)
	for {
		line, err := input.ReadBytes('\n')
		if len(line) > 0 {
			var message controlMessage
			if unmarshalErr := json.Unmarshal(line, &message); unmarshalErr != nil {
				done <- unmarshalErr
				return
			}

			switch message.Type {
			case "terminal.frame":
				if message.Bytes == "" {
					continue
				}
				frame, decodeErr := base64.StdEncoding.DecodeString(message.Bytes)
				if decodeErr != nil {
					done <- decodeErr
					return
				}
				if _, writeErr := output.Write(frame); writeErr != nil {
					done <- writeErr
					return
				}
			case "terminal.closed":
				done <- nil
				return
			}
		}

		if err != nil {
			done <- err
			return
		}
	}
}

func closePopup(socketPath string) error {
	if socketPath == "" {
		return nil
	}

	connection, err := net.DialTimeout("unix", socketPath, 200*time.Millisecond)
	if err != nil {
		return err
	}
	defer connection.Close()

	return sendControl(connection, socketRequest{
		ID:     "herdr-somars-close",
		Method: "popup.close",
		Params: map[string]any{},
	})
}

func terminalSize() (int, int) {
	command := exec.Command("stty", "size")
	command.Stdin = os.Stdin
	output, err := command.Output()
	if err != nil {
		return 80, 24
	}

	fields := strings.Fields(string(output))
	if len(fields) != 2 {
		return 80, 24
	}
	rows, rowsErr := strconv.Atoi(fields[0])
	cols, colsErr := strconv.Atoi(fields[1])
	if rowsErr != nil || colsErr != nil || rows < 1 || cols < 1 {
		return 80, 24
	}
	return cols, rows
}

func setRawTerminal() (func(), error) {
	savedCommand := exec.Command("stty", "-g")
	savedCommand.Stdin = os.Stdin
	saved, err := savedCommand.Output()
	if err != nil {
		return nil, err
	}

	rawCommand := exec.Command("stty", "raw", "-echo")
	rawCommand.Stdin = os.Stdin
	if err := rawCommand.Run(); err != nil {
		return nil, err
	}

	restore := func() {
		restoreCommand := exec.Command("stty", strings.TrimSpace(string(saved)))
		restoreCommand.Stdin = os.Stdin
		_ = restoreCommand.Run()
	}
	return restore, nil
}

func readInput(events chan<- []byte) {
	buffer := make([]byte, 4096)
	for {
		count, err := os.Stdin.Read(buffer)
		if count > 0 {
			data := append([]byte(nil), buffer[:count]...)
			events <- data
		}
		if err != nil {
			close(events)
			return
		}
	}
}

func environmentOrDefault(name, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}

func run(terminalID string) error {
	restore, err := setRawTerminal()
	if err != nil {
		return fmt.Errorf("set terminal raw: %w", err)
	}
	defer restore()

	cols, rows := terminalSize()
	herdrBin := environmentOrDefault("HERDR_BIN_PATH", "herdr")
	control := exec.Command(
		herdrBin,
		"terminal", "session", "control", terminalID,
		"--cols", strconv.Itoa(cols),
		"--rows", strconv.Itoa(rows),
	)
	control.Stderr = io.Discard
	controlInput, err := control.StdinPipe()
	if err != nil {
		return err
	}
	controlOutput, err := control.StdoutPipe()
	if err != nil {
		return err
	}
	if err := control.Start(); err != nil {
		return err
	}

	processDone := make(chan struct{})
	go func() {
		_ = control.Wait()
		close(processDone)
	}()

	framesDone := make(chan error, 1)
	go readFrames(controlOutput, os.Stdout, framesDone)

	released := false
	release := func() {
		if released {
			return
		}
		released = true
		_ = sendControl(controlInput, map[string]string{"type": "terminal.release"})
	}
	defer func() {
		release()
		_ = controlInput.Close()
		select {
		case <-processDone:
		case <-time.After(time.Second):
			_ = control.Process.Kill()
			<-processDone
		}
	}()

	inputEvents := make(chan []byte)
	go readInput(inputEvents)

	filter := inputFilter{}
	var timer *time.Timer
	var timerChannel <-chan time.Time
	armTimer := func() {
		if timer == nil {
			timer = time.NewTimer(100 * time.Millisecond)
		} else {
			if !timer.Stop() {
				select {
				case <-timer.C:
				default:
				}
			}
			timer.Reset(100 * time.Millisecond)
		}
		timerChannel = timer.C
	}
	stopTimer := func() {
		if timer == nil {
			return
		}
		if !timer.Stop() {
			select {
			case <-timer.C:
			default:
			}
		}
		timerChannel = nil
	}

	for {
		select {
		case data, ok := <-inputEvents:
			if !ok {
				return nil
			}
			forwarded, toggled := filter.Feed(data)
			if len(forwarded) > 0 {
				if err := sendInput(controlInput, forwarded); err != nil {
					return err
				}
			}
			if toggled {
				stopTimer()
				release()
				_ = closePopup(os.Getenv("HERDR_SOCKET_PATH"))
				return nil
			}
			if filter.pendingEscape {
				armTimer()
			} else {
				stopTimer()
			}
		case <-timerChannel:
			if pending := filter.Flush(); len(pending) > 0 {
				if err := sendInput(controlInput, pending); err != nil {
					return err
				}
			}
			timerChannel = nil
		case err := <-framesDone:
			if err != nil && err != io.EOF {
				return err
			}
			return nil
		case <-processDone:
			return nil
		}
	}
}

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintln(os.Stderr, "usage: herdr-somars-relay <terminal-id>")
		os.Exit(2)
	}
	if err := run(os.Args[1]); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
