--------------------------------------------------------------------------------
--- Window Management
--------------------------------------------------------------------------------
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
