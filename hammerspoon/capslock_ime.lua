-- ============================================================================
-- [Module] Caps Lock 极速切换输入法 (hidutil F18 + KeyDown 零延迟接管)
-- ============================================================================
do
    local chineseSourceIDs = {
        "com.bytedance.inputmethod.doubaoime.pinyin",
        "com.apple.inputmethod.SCIM.ITABC",
    }
    local lastChineseSourceID = chineseSourceIDs[1]
    local englishSourceID = "com.apple.keylayout.ABC"

    -- 1. 驱动层映射 Caps Lock (0x700000039) -> F18 (0x70000006D)
    hs.execute([[hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006D}]}']])

    -- 2. 自动兼容 ABC / U.S. 英文键盘布局
    for _, id in ipairs(hs.keycodes.layouts(true)) do
        if id == "com.apple.keylayout.ABC" or id == "com.apple.keylayout.US" then
            englishSourceID = id
            break
        end
    end

    -- 3. 切换中英文状态
    local function toggleInputSource()
        local current = hs.keycodes.currentSourceID()
        local isChineseSource = false
        for _, sourceID in ipairs(chineseSourceIDs) do
            if current == sourceID then
                isChineseSource = true
                lastChineseSourceID = current
                break
            end
        end

        if isChineseSource then
            if not hs.keycodes.setLayout("ABC") and not hs.keycodes.setLayout("U.S.") then
                hs.keycodes.currentSourceID(englishSourceID)
            end
        else
            hs.keycodes.currentSourceID(lastChineseSourceID)
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
