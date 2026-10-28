--------------------------------------------------------------------------------
--- Quick Open Applications
--------------------------------------------------------------------------------
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
    C = "Google Chrome",
    U = "Claude",
    T = "Ghostty",
    X = "Xcode",
    V = "Visual Studio Code",
    H = "Things3",
    N = "Notes",
    J = "Antigravity",
    G = "Gemini",
    O = "Obsidian",
    P = "Photos"
}

for key, app in pairs(apps) do
    hs.hotkey.bind({"alt"}, key, open(app))
end
