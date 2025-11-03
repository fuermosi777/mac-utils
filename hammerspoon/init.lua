--- functions
function chrome_switch_to(menuItem)
    return function()
        hs.application.launchOrFocus("Google Chrome")
        local chrome = hs.appfinder.appFromName("Google Chrome")
        chrome:selectMenuItem(menuItem, true)
    end
end

function chrome_active_tab_with_name(re)
    return function()
        hs.osascript.javascript([[
              var chrome = Application('Google Chrome');
              chrome.activate();
              var wins = chrome.windows;
              var re = new RegExp(']] .. re .. [[');
              function main() {
                  for (var i = 0; i < wins.length; i++) {
                      var win = wins.at(i);
                      var tabs = win.tabs;
                      for (var j = 0; j < tabs.length; j++) {
                      var tab = tabs.at(j);
                      tab.title(); j;
                      if (tab.title().match(re)) {
                              win.activeTabIndex = j + 1;
                              return;
                          }
                      }
                  }
              }
              main();
          ]])
    end
end

function open(name)
    return function()
        hs.application.launchOrFocus(name)
        if name == 'Finder' then
            hs.appfinder.appFromName(name):activate()
        end
    end
end

function openChromeApp(name)
    return function()
        -- Be sure to get the real name of the app (Use ls -a to check).
        hs.application.launchOrFocus(os.getenv('HOME') .. '/Applications/Chrome Apps.localized/' .. name .. '.app')
    end
end

function sleep()
    hs.caffeinate.systemSleep()
end

function screenWidthFraction(ratio)
    local win = hs.window.focusedWindow()
    local screenFrame = win:screen():frame()
    screenFrame = win:screen():absoluteToLocal(screenFrame)
    return math.floor(screenFrame.w * ratio)
end

function screenHeightFraction(ratio)
    local win = hs.window.focusedWindow()
    local screenFrame = win:screen():frame()
    screenFrame = win:screen():absoluteToLocal(screenFrame)
    return math.floor(screenFrame.h * ratio)
end

function snap(dir)
    return function()
        local win = hs.window.focusedWindow()
        local frame = win:frame()
        local screenFrame = win:screen():frame()
        frame = win:screen():absoluteToLocal(frame)
        screenFrame = win:screen():absoluteToLocal(screenFrame)
        local x = frame.x
        local y = frame.y
        local w = frame.w
        local h = frame.h

        if dir == 'right' then
            if x < 0 then -- overflow left
                frame.x = 0
                frame.w = math.min(frame.w, screenFrame.w)
            elseif x == 0 then -- attached left, expand to full and then shrink
                if w < screenWidthFraction(1 / 4) then -- win width less than 33%
                    frame.w = screenWidthFraction(1 / 4)
                elseif w < screenWidthFraction(1 / 2) then -- win width less than 50%
                    frame.w = screenWidthFraction(1 / 2)
                elseif w < screenWidthFraction(3 / 4) then -- win with less than 67%
                    frame.w = screenWidthFraction(3 / 4)
                elseif w < screenFrame.w then -- win not full screen
                    frame.w = screenFrame.w
                else -- already full with, start shrink
                    frame.w = screenWidthFraction(3 / 4)
                    frame.x = screenFrame.w - frame.w
                end
            elseif x + frame.w < screenFrame.w then -- gap on right side, attaching right
                frame.x = screenFrame.w - frame.w
            else -- already attached right or overflow right, shrink
                frame.w = screenFrame.w - x
                if w > screenWidthFraction(3 / 4) then
                    frame.w = screenWidthFraction(3 / 4)
                    frame.x = screenFrame.w - frame.w
                elseif w > screenWidthFraction(1 / 2) then
                    frame.w = screenWidthFraction(1 / 2)
                    frame.x = screenFrame.w - frame.w
                elseif w > screenWidthFraction(1 / 3) then
                    frame.w = screenWidthFraction(1 / 3)
                    frame.x = screenFrame.w - frame.w
                end
            end
        elseif dir == 'left' then
            if x + w > screenFrame.w then -- overflow right, un-overflow
                frame.x = screenFrame.w - w
                frame.w = math.min(frame.w, screenFrame.w)
            elseif x + w == screenFrame.w then -- attached right, expand to full then shrink
                if w < screenWidthFraction(1 / 4) then -- win with less than 33%
                    frame.w = screenWidthFraction(1 / 4)
                    frame.x = screenFrame.w - frame.w
                elseif w < screenWidthFraction(1 / 2) then -- win width less than 50%
                    frame.w = screenWidthFraction(1 / 2)
                    frame.x = screenFrame.w - frame.w
                elseif w < screenWidthFraction(3 / 4) then -- win with less than 67%
                    frame.w = screenWidthFraction(3 / 4)
                    frame.x = screenFrame.w - frame.w
                elseif w < screenFrame.w then -- win almost full width
                    frame.w = screenFrame.w
                    frame.x = screenFrame.w - frame.w
                else -- full width, start shrinking
                    frame.w = screenWidthFraction(3 / 4)
                end
            elseif x > 0 then -- gap on left
                frame.x = 0
            else -- already attached left or overflow left
                frame.x = 0
                if w > screenWidthFraction(3 / 4) then
                    frame.w = screenWidthFraction(3 / 4)
                elseif w > screenWidthFraction(1 / 2) then
                    frame.w = screenWidthFraction(1 / 2)
                elseif w > screenWidthFraction(1 / 3) then
                    frame.w = screenWidthFraction(1 / 3)
                end
            end
        elseif dir == 'up' then
            if y == screenFrame.y then -- attached to top
                -- shrink
                if h > screenHeightFraction(2 / 3) then
                    frame.h = screenHeightFraction(2 / 3)
                elseif h > screenHeightFraction(1 / 2) then
                    frame.h = screenHeightFraction(1 / 2)
                else
                    frame.h = screenHeightFraction(1 / 3)
                end
            elseif y + h == screenFrame.h + screenFrame.y then -- attached to bottom
                if h < screenHeightFraction(1 / 3) then
                    frame.h = screenHeightFraction(1 / 3)
                    frame.y = screenFrame.h - frame.h + screenFrame.y
                elseif h < screenHeightFraction(1 / 2) then
                    frame.h = screenHeightFraction(1 / 2)
                    frame.y = screenFrame.h - frame.h + screenFrame.y
                elseif h < screenHeightFraction(2 / 3) then
                    frame.h = screenHeightFraction(2 / 3)
                    frame.y = screenFrame.h - frame.h + screenFrame.y
                else
                    frame.y = screenFrame.y
                    frame.h = screenFrame.h
                end
            elseif y + h > screenFrame.h + screenFrame.y then -- overflow bottom, attaching to bottom
                frame.y = screenFrame.h - h + screenFrame.y
            else -- not attached
                frame.y = screenFrame.y
            end
        elseif dir == 'down' then
            if y + h == screenFrame.h + screenFrame.y then -- attach to bottom
                if h > screenHeightFraction(2 / 3) then
                    frame.h = screenHeightFraction(2 / 3)
                    frame.y = screenFrame.h - frame.h + screenFrame.y
                elseif h > screenHeightFraction(1 / 2) then
                    frame.h = screenHeightFraction(1 / 2)
                    frame.y = screenFrame.h - frame.h + screenFrame.y
                elseif h > screenHeightFraction(1 / 3) then
                    frame.h = screenHeightFraction(1 / 3)
                    frame.y = screenFrame.h - frame.h + screenFrame.y
                end
            elseif y == screenFrame.y then -- attach to top
                if h < screenHeightFraction(1 / 3) then
                    frame.h = screenHeightFraction(1 / 3)
                elseif h < screenHeightFraction(1 / 2) then
                    frame.h = screenHeightFraction(1 / 2)
                elseif h < screenHeightFraction(2 / 3) then
                    frame.h = screenHeightFraction(2 / 3)
                else
                    frame.y = screenFrame.y
                    frame.h = screenFrame.h
                end
            elseif y + h > screenFrame.h + screenFrame.y then -- overflow bottom do nothing
            else
                frame.y = screenFrame.h - h + screenFrame.y
            end
        end

        frame = win:screen():localToAbsolute(frame)
        win:setFrame(frame)
    end
end

function send_window_prev_monitor()
    local win = hs.window.focusedWindow()
    local nextScreen = win:screen():previous()
    win:moveToScreen(nextScreen)
end

function send_window_next_monitor()
    local win = hs.window.focusedWindow()
    local nextScreen = win:screen():next()
    win:moveToScreen(nextScreen)
end

--- open different Chrome users
hs.hotkey.bind({"alt"}, "1", chrome_switch_to({"Profiles", "Hao (google.com)"}))
hs.hotkey.bind({"alt"}, "2", chrome_switch_to({"Profiles", "Hao"}))
hs.hotkey.bind({"alt"}, "`", chrome_switch_to({"File", "New Incognito Window"}))

--- quick open applications
hs.hotkey.bind({"alt"}, "E", open("Finder"))
hs.hotkey.bind({"alt"}, "W", open("WeChat"))
hs.hotkey.bind({"alt"}, "M", open("Messages"))
hs.hotkey.bind({"alt"}, "C", open("Google Chrome"))
hs.hotkey.bind({"alt"}, "T", open("iTerm"))
hs.hotkey.bind({"alt"}, "X", open("Xcode"))
hs.hotkey.bind({"alt"}, "S", open("Sublime Text"))
hs.hotkey.bind({"alt"}, "V", open("Visual Studio Code"))
hs.hotkey.bind({"alt"}, "H", open("Things3"))
hs.hotkey.bind({"alt"}, "N", open("Notes"))
hs.hotkey.bind({"alt"}, "R", open("Reminders"))
hs.hotkey.bind({"alt"}, "D", openChromeApp("Cider-V"))
hs.hotkey.bind({"alt"}, "A", openChromeApp("Google Chat"))
--- sleep
hs.hotkey.bind({"shift", "alt", "command"}, "DELETE", sleep)

--- window
hs.window.animationDuration = 0
hs.hotkey.bind({"alt", "cmd"}, "Right", snap('right'))
hs.hotkey.bind({"alt", "cmd"}, "Left", snap('left'))
hs.hotkey.bind({"alt", "cmd"}, "Up", snap('up'))
hs.hotkey.bind({"alt", "cmd"}, "Down", snap('down'))
hs.hotkey.bind({"shift", "alt", "cmd"}, "Left", send_window_prev_monitor)
hs.hotkey.bind({"shift", "alt", "cmd"}, "Right", send_window_next_monitor)

-- Function from AutoMuteOnSleep Spoon
function muteNonBluetoothOutputDevices(state)
    if state == hs.caffeinate.watcher.systemDidWake or state == hs.caffeinate.watcher.systemWillSleep then
        local devices = hs.audiodevice.allOutputDevices()
    
        for _, device in ipairs(devices) do
            if device and device:transportType() ~= 'Bluetooth' then
                -- Try to set volume to 0, if that fails (e.g. no volume control), mute it
                _ = device:setVolume(0) or device:setMuted(true)
            end
        end
    end
end
-- This creates the watcher and starts it, using the function defined above.
local sleepWatcher = hs.caffeinate.watcher.new(muteNonBluetoothOutputDevices)
sleepWatcher:start()

--- key macros
function keyStrokes(str)
    return function()
        hs.eventtap.keyStrokes(str)
    end
end
hs.hotkey.bind({"alt", "cmd"}, "L", keyStrokes("console.log("))
