--------------------------------------------------------------------------------
--- Chrome Profiles & Apps
--------------------------------------------------------------------------------
local function chromeSwitchTo(menuItem)
    return function()
        local chrome = hs.application.get("com.google.Chrome")
        if not chrome then
            hs.application.launchOrFocusByBundleID("com.google.Chrome")
            hs.timer.doAfter(0.5, function()
                local c = hs.application.get("com.google.Chrome")
                if c then c:selectMenuItem(menuItem, true) end
            end)
        else
            chrome:activate()
            chrome:selectMenuItem(menuItem, true)
        end
    end
end

-- Profiles
hs.hotkey.bind({"alt"}, "1", chromeSwitchTo({"Profiles", "Hao"}))
hs.hotkey.bind({"alt"}, "2", chromeSwitchTo({"Profiles", "Hao (Google)"}))
hs.hotkey.bind({"alt"}, "`", chromeSwitchTo({"File", "New Incognito Window"}))
