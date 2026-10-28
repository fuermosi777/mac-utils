--------------------------------------------------------------------------------
--- Key Macros
--------------------------------------------------------------------------------
local function keyStrokes(str)
    return function() hs.eventtap.keyStrokes(str) end
end

hs.hotkey.bind({"alt", "cmd"}, "L", keyStrokes("console.log("))
