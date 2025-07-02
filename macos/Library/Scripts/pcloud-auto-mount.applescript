#!/usr/bin/osascript

-- Wait for pCloud to fully start
delay 10

tell application "pCloud Drive"
    activate
end tell

-- Wait for the window to appear
delay 2

tell application "System Events"
    tell process "pCloud Drive"
        -- Try to click the "Enable Drive" button
        try
            click button "Enable Drive" of window 1
        on error
            -- Drive might already be enabled
        end try
    end tell
end tell

-- Hide pCloud window after enabling
tell application "System Events"
    set visible of process "pCloud Drive" to false
end tell