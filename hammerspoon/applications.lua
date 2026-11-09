--------------------------------------------------------------------------------
--- Quick Open Applications (智能双端自适应: 家里 vs 公司)
--------------------------------------------------------------------------------
local function open(target)
    return function()
        -- 支持传入列表进行优先匹配 (例如 {"Jetski Web", "Jetski", "Antigravity"})
        local candidates = type(target) == "table" and target or {target}
        local home = os.getenv('HOME')

        for _, name in ipairs(candidates) do
            -- 1. 检查 ~/Applications/Chrome Apps.localized/ 下的 Chrome PWA 应用
            local chromeAppPath = home .. '/Applications/Chrome Apps.localized/' .. name .. '.app'
            if hs.fs.attributes(chromeAppPath) then
                hs.application.launchOrFocus(chromeAppPath)
                return
            end

            -- 2. 检查是否正在运行该名称的应用
            local runningApp = hs.application.get(name)
            -- 注意：不能只用 activate()，它不会重新打开已关闭的窗口（如微信关掉主窗口后挂在后台）
            -- launchOrFocusByBundleID 会发送 reopen 事件，把窗口带回来
            if runningApp then
                local bid = runningApp:bundleID()
                if not (bid and hs.application.launchOrFocusByBundleID(bid)) then
                    runningApp:activate()
                end
                return
            end

            -- 3. 检查系统常规已安装的应用 (/Applications, ~/Applications 等)
            if hs.application.launchOrFocus(name) then
                if name == 'Finder' then
                    local f = hs.appfinder.appFromName(name)
                    if f then f:activate() end
                end
                return
            end
        end
    end
end

-- 智能检测终端：Ghostty (家里) vs iTerm/iTerm2 (公司) vs 系统原生 Terminal
local function getPreferredTerminal()
    local terminalCandidates = {"Ghostty", "iTerm", "iTerm2", "Alacritty", "Terminal"}
    for _, term in ipairs(terminalCandidates) do
        if hs.application.get(term) then
            return term
        end
    end
    for _, term in ipairs(terminalCandidates) do
        if hs.application.infoForBundlePath("/Applications/" .. term .. ".app") or
           hs.application.infoForBundlePath(hs.fs.pathToAbsolute("~/Applications/" .. term .. ".app") or "") then
            return term
        end
    end
    return "Terminal"
end

local apps = {
    E = "Finder",
    W = "WeChat",
    -- M: 公司优先打开 Google Chat (Chrome App)，家里没有时打开 Messages
    M = {"Google Chat", "Messages"},
    C = "Google Chrome",
    U = "Claude",
    -- T: 家里 Ghostty，公司 iTerm
    T = getPreferredTerminal(),
    X = "Xcode",
    V = "Visual Studio Code",
    H = "Things3",
    N = "Notes",
    -- J: 公司优先打开 Chrome App Jetski Web，家里打开本地 Jetski / Antigravity
    J = {"Jetski Web", "Jetski", "Antigravity"},
    -- A: 直接打开原生 Jetski / Antigravity
    A = {"Jetski", "Antigravity"},
    -- D: 打开 Cider (Chrome App 或本地 App)
    D = "Cider",
    G = "Gemini",
    O = "Obsidian",
    P = "Photos"
}

for key, target in pairs(apps) do
    hs.hotkey.bind({"alt"}, key, open(target))
end
