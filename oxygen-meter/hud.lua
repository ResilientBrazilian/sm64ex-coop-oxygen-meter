local wheel, inf, math_floor, sw, sh, djui_hud_set_resolution, djui_hud_world_pos_to_screen_pos, djui_hud_set_render_behind_hud, clampf, render, renderTimer, if_then_else, lerpColor, audio_stream_play, hook_event =
    0, math.huge, math.floor, djui_hud_get_screen_width, djui_hud_get_screen_height, djui_hud_set_resolution,
    djui_hud_world_pos_to_screen_pos, djui_hud_set_render_behind_hud, clampf, renderHalf, renderTimer, if_then_else,
    lerpColor, audio_stream_play, hook_event

hook_event(HOOK_ON_HUD_RENDER, function()
    clock = clock + 1
    scWidth = sw()
    scHeight = sh()

    local out = { x = 0, y = 0, z = 0 }
    local pos = { x = m.marioObj.header.gfx.pos.x, y = m.pos.y + 190, z = m.marioObj.header.gfx.pos.z + 50 }
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_world_pos_to_screen_pos(pos, out)
    djui_hud_set_render_behind_hud(true)

    local pX = clampf(out.x, 0, sw())
    local pY = clampf(out.y, 0, sh())

    if air > 0 then
        wheel = lerpNum(wheel, clampf(2 ^ 16 - ((air / maxAir) * 2 ^ 16), 0, inf), 0.3)
    elseif air >= maxAir then
        wheel = 0
    else
        wheel = 2 ^ 16
    end

    if (wheel > 16 and m.pos.y < m.waterLevel + 1000) then
        if m.health <= 255 or m.action == ACT_CAUGHT_IN_WHIRLPOOL then return end
        local color = { 0, 0, 0 }
        if air <= 0 and clock / 2 == math_floor(clock / 2) then
            color = { 255, 0, 0 }
        else
            color = { 0, 0, 0 }
        end
        render(color, 0, pX, pY)
        render(color, 2 ^ 15, pX, pY)

        tpX = pX
        tpY = pY

        local displayText = if_then_else(showTimer == true,
            (air / 30) / clampf(totIncAir, 1, 2 ^ 31),
            ((air / maxAir) * 100))
        if wheel < 2 ^ 15 then
            local color = lerpColor(255, 255, 0, 0, 255, 0, (air / maxAir) * 2 - 1)
            if cold() then
                color = lerpColor(0, 255, 255, 0, 255, 0, (air / maxAir) * 2 - 1)
            end
            render(color, wheel + 2 ^ 15, pX, pY)
            render(color, 0, pX, pY)
            if showTimer == true and math.abs(totIncAir) > 0 then
                renderTimer(color, displayText, pX, pY)
            end
        else
            if air <= 0 then
                if clock / 2 == math_floor(clock / 2) then
                    audio_stream_play(beep, true, 2.2)
                end
            else
                local color = lerpColor(255, 0, 0, 255, 255, 0, (air / maxAir) * 2)
                if cold() then
                    color = lerpColor(255, 255, 255, 0, 255, 255, (air / maxAir) * 2)
                end
                render(color, wheel + 2 ^ 15, pX, pY)
                render({ 0, 0, 0 }, 2 ^ 15, pX, pY)
                if showTimer == true and math.abs(totIncAir) > 0 then
                    renderTimer(color, displayText, pX, pY)
                end
            end
        end
    end
end)

local function cmd(msg)
    if msg == "on" then
        djui_chat_message_create("\\#00ff00\\[!]\\#ffffff\\ Oxygen timer is now \\#00ff00\\ON")
        showTimer = true
    elseif msg == "off" then
        djui_chat_message_create("\\#00ff00\\[!]\\#ffffff\\ Oxygen timer is now \\#ff0000\\OFF")
        showTimer = false
    else
        djui_chat_message_create(
            "\\#ff0000\\[!!]\\#ffffff\\ Invalid command usage!\n\\#aaaaaa\\/o2-timer \\#1899aa\\[on/off]")
    end
    return true
end

hook_chat_command("o2-timer", "\\#22bbff\\[on/off]", cmd)
