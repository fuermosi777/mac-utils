-- ============================================================================
-- [Module] Caps Lock 极速切换输入法 (hidutil F18 + KeyDown 零延迟接管)
-- ============================================================================
do
    -- 1. 驱动层映射 Caps Lock (0x700000039) -> F18 (0x70000006D)
    hs.execute([[hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006D}]}']])

    -- 2. 自动兼容 ABC / U.S. 英文键盘布局
    local englishSourceID = "com.apple.keylayout.ABC"
    for _, id in ipairs(hs.keycodes.layouts(true) or {}) do
        if id == "com.apple.keylayout.ABC" or id == "com.apple.keylayout.US" then
            englishSourceID = id
            break
        end
    end

    -- 常见中文输入法
    local chineseCandidates = {
        "com.bytedance.inputmethod.doubaoime.pinyin", -- 豆包拼音 (家)
        "com.apple.inputmethod.SCIM.ITABC",          -- 原生拼音 (公司)
        "im.rime.inputmethod.Squirrel.Rime",
        "com.sogou.inputmethod.sogou.pinyin",
    }

    local function getChineseSourceID()
        -- 注意：methods() 默认返回显示名称（如"豆包输入法"），必须传 true 才返回 source ID
        local allMethods = hs.keycodes.methods(true) or {}
        local set = {}
        for _, m in ipairs(allMethods) do set[m] = true end
        for _, cand in ipairs(chineseCandidates) do
            if set[cand] then return cand end
        end
        return "com.apple.inputmethod.SCIM.ITABC"
    end

    local chineseSourceID = getChineseSourceID()

    -- 3. 切换中英文状态
    local function toggleInputSource()
        local current = hs.keycodes.currentSourceID() or ""
        -- 如果当前是中文（包含 SCIM、doubao、inputmethod、pinyin 等）
        local isChinese = string.find(current, "SCIM") or
                          string.find(current, "doubao") or
                          string.find(current, "pinyin") or
                          string.find(current, "rime") or
                          string.find(current, "inputmethod")

        if isChinese then
            chineseSourceID = current -- 记住上次用的中文输入法
            if not hs.keycodes.setLayout("ABC") and not hs.keycodes.setLayout("U.S.") then
                hs.keycodes.currentSourceID(englishSourceID)
            end
        else
            hs.keycodes.currentSourceID(chineseSourceID)
        end
    end

    -- 4. 销毁旧实例（防止 Reload Config 时重复绑定）并启动底层监听
    if _G.CapsLockTap then _G.CapsLockTap:stop() end
    if _G.CapsLockWatchdog then _G.CapsLockWatchdog:stop() end

    _G.CapsLockTap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)
        if event:getKeyCode() == 79 then -- 79 = F18
            if event:getType() == hs.eventtap.event.types.keyDown then
                if event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat) == 0 then
                    toggleInputSource()
                end
            end
            return true -- 吞掉 F18 的 keyDown 和 keyUp，防止干扰中文输入法状态机
        end
        return false
    end):start()

    -- 5. 守护定时器：防止系统休眠唤醒后 eventtap 被 macOS 断开
    _G.CapsLockWatchdog = hs.timer.doEvery(5, function()
        if not _G.CapsLockTap:isEnabled() then
            _G.CapsLockTap:start()
        end
    end)
end
-- ============================================================================
-- [End Module] Caps Lock 极速切换输入法
-- ============================================================================
