--------------------------------------------------------------------------------
--- System
--------------------------------------------------------------------------------
hs.hotkey.bind({"shift", "alt", "cmd"}, "DELETE", function()
    hs.execute("/usr/bin/pmset displaysleepnow")
end)

--------------------------------------------------------------------------------
--- Monitor input (T32UD-40: DP = Mac mini, USB-C = MacBook)
--------------------------------------------------------------------------------
local T32_UUID = "27541ADE-B91C-4421-83B7-448A178085F1"

local LEN_UUID = "76B828DE-DDB7-4018-9AFD-3591FB31C8CD"

local function screenWithUUID(uuid)
    for _, screen in ipairs(hs.screen.allScreens()) do
        if screen:getUUID() == uuid then return screen end
    end
end

local function ddcInput(value)
    hs.task.new("/opt/homebrew/bin/m1ddc", nil,
        {"display", T32_UUID, "set", "input", tostring(value)}):start()
end

-- 切给 MacBook 后 macOS 会留一块幽灵屏；先把它镜像到 LEN，窗口和鼠标就不会跑进去
hs.hotkey.bind({"shift", "alt", "cmd"}, "M", function()
    local t32, len = screenWithUUID(T32_UUID), screenWithUUID(LEN_UUID)
    if t32 and len then
        print("mirror T32UD-40 ->", len:name(), t32:mirrorOf(len))
    else
        print("mirror skipped: T32UD-40 or LEN not found")
        for _, screen in ipairs(hs.screen.allScreens()) do
            print("  screen:", screen:name(), screen:getUUID())
        end
    end
    hs.timer.doAfter(1, function() ddcInput(17) end)  -- MacBook (USB-C)
end)

-- 镜像后 T32UD-40 不在 allScreens() 里，Reload Config 后也拿不回它的引用，
-- 所以用 bin/unmirror.swift 直接调 CoreGraphics 取消镜像（首次使用或源码更新时自动编译）
local UNMIRROR_SRC = hs.configdir .. "/bin/unmirror.swift"
local UNMIRROR_BIN = os.getenv("HOME") .. "/Library/Caches/hammerspoon/unmirror"

local function unmirror()
    local src, bin = hs.fs.attributes(UNMIRROR_SRC), hs.fs.attributes(UNMIRROR_BIN)
    local cmd = string.format("'%s'", UNMIRROR_BIN)
    if not bin or bin.modification < src.modification then
        cmd = string.format("mkdir -p '%s' && /usr/bin/swiftc -O '%s' -o '%s' && %s",
            UNMIRROR_BIN:match("(.*)/"), UNMIRROR_SRC, UNMIRROR_BIN, cmd)
    end
    hs.task.new("/bin/sh", function(code, out, err)
        print("unmirror:", code, out, err)
    end, {"-c", cmd}):start()
end

hs.hotkey.bind({"shift", "alt", "cmd"}, "N", function()
    ddcInput(15)  -- Mac mini (DP)
    unmirror()
end)
