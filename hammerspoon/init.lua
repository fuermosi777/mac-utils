--------------------------------------------------------------------------------
--- Quick Open Applications
--------------------------------------------------------------------------------
do
    local function open(name)
        return function()
            hs.application.launchOrFocus(name)
            if name == 'Finder' then
                hs.appfinder.appFromName(name):activate()
            end
        end
    end

    local apps = {
        E = "Finder",
        W = "WeChat",
        M = "Messages",
        C = "Claude",
        T = "iTerm",
        X = "Xcode",
        V = "Visual Studio Code",
        H = "Things3",
        N = "Notes",
        A = "Antigravity",
        G = "Gemini"
    }
    for key, app in pairs(apps) do
        hs.hotkey.bind({"alt"}, key, open(app))
    end
end

--------------------------------------------------------------------------------
--- Chrome Profiles & Apps
--------------------------------------------------------------------------------
do
    local function chromeSwitchTo(menuItem)
        return function()
            hs.application.launchOrFocus("Google Chrome")
            local chrome = hs.appfinder.appFromName("Google Chrome")
            if chrome then chrome:selectMenuItem(menuItem, true) end
        end
    end

    local function openChromeApp(name)
        return function()
            local path = os.getenv('HOME') .. '/Applications/Chrome Apps.localized/' .. name .. '.app'
            hs.application.launchOrFocus(path)
        end
    end

    -- Profiles
    hs.hotkey.bind({"alt"}, "1", chromeSwitchTo({"Profiles", "Hao"}))
    hs.hotkey.bind({"alt"}, "2", chromeSwitchTo({"Profiles", "Hao (Google)"}))
    hs.hotkey.bind({"alt"}, "`", chromeSwitchTo({"File", "New Incognito Window"}))
    
    -- Work related apps
    hs.hotkey.bind({"alt"}, "D", openChromeApp("Cider-V"))
end

--------------------------------------------------------------------------------
--- Key Macros
--------------------------------------------------------------------------------
do
    local function keyStrokes(str)
        return function() hs.eventtap.keyStrokes(str) end
    end
    
    hs.hotkey.bind({"alt", "cmd"}, "L", keyStrokes("console.log("))
end

--------------------------------------------------------------------------------
--- System
--------------------------------------------------------------------------------
do
    hs.hotkey.bind({"shift", "alt", "cmd"}, "DELETE", function()
        hs.caffeinate.systemSleep()
    end)
end

--------------------------------------------------------------------------------
--- Window Management
--------------------------------------------------------------------------------
do
    hs.window.animationDuration = 0

    local function moveScreen(dir)
        return function()
            local win = hs.window.focusedWindow()
            if not win then return end
            win:moveToScreen(dir == 'next' and win:screen():next() or win:screen():previous())
        end
    end

    local function snap(dir)
        return function()
            local win = hs.window.focusedWindow()
            if not win then return end

            local screen = win:screen()
            local frame = screen:absoluteToLocal(win:frame())
            local sFrame = screen:absoluteToLocal(screen:frame())

            local fw = function(r) return math.floor(sFrame.w * r) end
            local fh = function(r) return math.floor(sFrame.h * r) end
            
            local x, y, w, h = frame.x, frame.y, frame.w, frame.h

            if dir == 'right' then
                if x < 0 then
                    frame.x = 0; frame.w = math.min(w, sFrame.w)
                elseif x == 0 then
                    if w < fw(1/4) then frame.w = fw(1/4)
                    elseif w < fw(1/2) then frame.w = fw(1/2)
                    elseif w < fw(3/4) then frame.w = fw(3/4)
                    elseif w < sFrame.w then frame.w = sFrame.w
                    else frame.w = fw(3/4); frame.x = sFrame.w - frame.w end
                elseif x + w < sFrame.w then
                    frame.x = sFrame.w - w
                else
                    frame.w = sFrame.w - x
                    if w > fw(3/4) then frame.w = fw(3/4); frame.x = sFrame.w - frame.w
                    elseif w > fw(1/2) then frame.w = fw(1/2); frame.x = sFrame.w - frame.w
                    elseif w > fw(1/3) then frame.w = fw(1/3); frame.x = sFrame.w - frame.w end
                end
            elseif dir == 'left' then
                if x + w > sFrame.w then
                    frame.x = sFrame.w - w; frame.w = math.min(w, sFrame.w)
                elseif x + w == sFrame.w then
                    if w < fw(1/4) then frame.w = fw(1/4); frame.x = sFrame.w - frame.w
                    elseif w < fw(1/2) then frame.w = fw(1/2); frame.x = sFrame.w - frame.w
                    elseif w < fw(3/4) then frame.w = fw(3/4); frame.x = sFrame.w - frame.w
                    elseif w < sFrame.w then frame.w = sFrame.w; frame.x = sFrame.w - frame.w
                    else frame.w = fw(3/4) end
                elseif x > 0 then
                    frame.x = 0
                else
                    frame.x = 0
                    if w > fw(3/4) then frame.w = fw(3/4)
                    elseif w > fw(1/2) then frame.w = fw(1/2)
                    elseif w > fw(1/3) then frame.w = fw(1/3) end
                end
            elseif dir == 'up' then
                if y == sFrame.y then
                    if h > fh(2/3) then frame.h = fh(2/3)
                    elseif h > fh(1/2) then frame.h = fh(1/2)
                    else frame.h = fh(1/3) end
                elseif y + h == sFrame.h + sFrame.y then
                    if h < fh(1/3) then frame.h = fh(1/3); frame.y = sFrame.h - frame.h + sFrame.y
                    elseif h < fh(1/2) then frame.h = fh(1/2); frame.y = sFrame.h - frame.h + sFrame.y
                    elseif h < fh(2/3) then frame.h = fh(2/3); frame.y = sFrame.h - frame.h + sFrame.y
                    else frame.y = sFrame.y; frame.h = sFrame.h end
                elseif y + h > sFrame.h + sFrame.y then
                    frame.y = sFrame.h - h + sFrame.y
                else
                    frame.y = sFrame.y
                end
            elseif dir == 'down' then
                if y + h == sFrame.h + sFrame.y then
                    if h > fh(2/3) then frame.h = fh(2/3); frame.y = sFrame.h - frame.h + sFrame.y
                    elseif h > fh(1/2) then frame.h = fh(1/2); frame.y = sFrame.h - frame.h + sFrame.y
                    elseif h > fh(1/3) then frame.h = fh(1/3); frame.y = sFrame.h - frame.h + sFrame.y end
                elseif y == sFrame.y then
                    if h < fh(1/3) then frame.h = fh(1/3)
                    elseif h < fh(1/2) then frame.h = fh(1/2)
                    elseif h < fh(2/3) then frame.h = fh(2/3)
                    else frame.y = sFrame.y; frame.h = sFrame.h end
                elseif y + h > sFrame.h + sFrame.y then
                else
                    frame.y = sFrame.h - h + sFrame.y
                end
            end

            win:setFrame(screen:localToAbsolute(frame))
        end
    end

    hs.hotkey.bind({"alt", "cmd"}, "Right", snap('right'))
    hs.hotkey.bind({"alt", "cmd"}, "Left", snap('left'))
    hs.hotkey.bind({"alt", "cmd"}, "Up", snap('up'))
    hs.hotkey.bind({"alt", "cmd"}, "Down", snap('down'))
    
    hs.hotkey.bind({"shift", "alt", "cmd"}, "Left", moveScreen('prev'))
    hs.hotkey.bind({"shift", "alt", "cmd"}, "Right", moveScreen('next'))
end

--------------------------------------------------------------------------------
--- Mouse Buttons (MX Master 4: Button 5 & 6)
--------------------------------------------------------------------------------
do
    local BUTTON_SHOW_DESKTOP = 5
    local BUTTON_GEMINI = 6

    local function openGemini()
        hs.application.launchOrFocus("Gemini")
    end
    
    -- 只创建一个事件监听器，同时管理 5 号和 6 号键
    mxMasterTap = hs.eventtap.new({ hs.eventtap.event.types.otherMouseUp }, function(event)
        local buttonNumber = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
        
        if buttonNumber == BUTTON_SHOW_DESKTOP then
            -- 5号键：丝滑显示桌面
            hs.spaces.toggleShowDesktop()
            return true -- 拦截
            
        elseif buttonNumber == BUTTON_GEMINI then
            -- 6号键：直达 Gemini
            openGemini()
            return true -- 拦截
        end
        
        return false -- 其他鼠标键（如左、右、中键等）正常放行
    end):start()
end
