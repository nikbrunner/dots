package main

import (
	"encoding/base64"
	"encoding/json"
	"net"
	"path/filepath"
	"strings"
	"testing"
)

func TestInputFilter(t *testing.T) {
	filter := inputFilter{}

	forwarded, toggled := filter.Feed([]byte("abc"))
	if string(forwarded) != "abc" || toggled {
		t.Fatalf("ordinary input: got %q, toggled=%v", forwarded, toggled)
	}

	forwarded, toggled = filter.Feed([]byte{0x1b})
	if len(forwarded) != 0 || toggled {
		t.Fatalf("pending Alt+R: got %q, toggled=%v", forwarded, toggled)
	}

	forwarded, toggled = filter.Feed([]byte("r"))
	if len(forwarded) != 0 || !toggled {
		t.Fatalf("Alt+R: got %q, toggled=%v", forwarded, toggled)
	}

	forwarded, toggled = filter.Feed([]byte("x\x1bry"))
	if string(forwarded) != "xy" || !toggled {
		t.Fatalf("embedded Alt+R: got %q, toggled=%v", forwarded, toggled)
	}

	filter.Feed([]byte{0x1b})
	if got := filter.Flush(); string(got) != "\x1b" {
		t.Fatalf("standalone Escape: got %q", got)
	}
}

func TestReadFrames(t *testing.T) {
	frame := base64.StdEncoding.EncodeToString([]byte("ready"))
	input := "{\"type\":\"terminal.frame\",\"bytes\":\"" + frame + "\"}\n" +
		"{\"type\":\"terminal.closed\"}\n"
	var output captureWriter
	done := make(chan error, 1)

	readFrames(strings.NewReader(input), &output, done)

	if got := string(output.data); got != "ready" {
		t.Fatalf("frame output: got %q", got)
	}
	if err := <-done; err != nil {
		t.Fatalf("read frames: %v", err)
	}
}

func TestClosePopup(t *testing.T) {
	socketPath := filepath.Join(t.TempDir(), "herdr.sock")
	listener, err := net.Listen("unix", socketPath)
	if err != nil {
		t.Fatal(err)
	}
	defer listener.Close()

	received := make(chan socketRequest, 1)
	go func() {
		connection, acceptErr := listener.Accept()
		if acceptErr != nil {
			return
		}
		defer connection.Close()
		var request socketRequest
		if decodeErr := json.NewDecoder(connection).Decode(&request); decodeErr == nil {
			received <- request
		}
	}()

	if err := closePopup(socketPath); err != nil {
		t.Fatal(err)
	}

	request := <-received
	if request.ID != "herdr-somars-close" || request.Method != "popup.close" {
		t.Fatalf("popup request: got %#v", request)
	}
}

type captureWriter struct {
	data []byte
}

func (w *captureWriter) Write(data []byte) (int, error) {
	w.data = append(w.data, data...)
	return len(data), nil
}
