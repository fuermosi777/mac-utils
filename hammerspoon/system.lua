--------------------------------------------------------------------------------
--- System
--------------------------------------------------------------------------------
hs.hotkey.bind({"shift", "alt", "cmd"}, "DELETE", function()
    hs.execute("/usr/bin/pmset displaysleepnow")
end)

--------------------------------------------------------------------------------
--- Monitor input (T32UD-40: DP = Mac mini, USB-C = MacBook)
--------------------------------------------------------------------------------
local function monitorInput(value)
    return function()
        hs.task.new("/opt/homebrew/bin/m1ddc", nil,
            {"display", "27541ADE-B91C-4421-83B7-448A178085F1", "set", "input", tostring(value)}):start()
    end
end

hs.hotkey.bind({"shift", "alt", "cmd"}, "M", monitorInput(17))  -- MacBook (USB-C)
hs.hotkey.bind({"shift", "alt", "cmd"}, "N", monitorInput(15))  -- Mac mini (DP)
