-- Hammerspoon configuration for Environment Launcher
-- Add this to your ~/.hammerspoon/init.lua file

-- Environment Launcher hotkey (⌘+Shift+D)
hs.hotkey.bind({"cmd", "shift"}, "d", function()
    -- Launch in a new terminal window
    local script = [[
        tell application "Terminal"
            activate
            do script "~/.local/bin/dev-launcher"
        end tell
    ]]
    hs.osascript.applescript(script)
    
    -- Show notification
    hs.notify.new({
        title = "🚀 Environment Launcher",
        informativeText = "Opening development environment menu...",
        autoWithdraw = true,
        withdrawAfter = 2
    }):send()
end)

-- Alternative: Launch in iTerm2 if you prefer
hs.hotkey.bind({"cmd", "shift", "alt"}, "d", function()
    local script = [[
        tell application "iTerm"
            activate
            create window with default profile
            tell current session of current window
                write text "~/.local/bin/dev-launcher"
            end tell
        end tell
    ]]
    hs.osascript.applescript(script)
end)

-- Helper: Quick container cleanup (⌘+Shift+C)
hs.hotkey.bind({"cmd", "shift"}, "c", function()
    hs.execute("docker system prune -f")
    hs.notify.new({
        title = "🧹 Docker Cleanup",
        informativeText = "Unused containers and images removed",
        autoWithdraw = true,
        withdrawAfter = 3
    }):send()
end)