-- name: Oxygen Meter \\#00ffbb\\v1.2
-- description: Separates the oxygen/drowning function from the power meter into its own meter. The player starts taking damage once the oxygen meter runs out.\n\\#888888\\This does not apply to toxic gas.\n\n\\#ffffff\\> mod by \\#3f3f3f\\R\\#4f4f4f\\e\\#5f5f5f\\s\\#6f6f6f\\i\\#7f7f7f\\l\\#9f9f9f\\i\\#bfbfbf\\e\\#dfdfdf\\n\\#ffffff\\t\\#ffffff\\B\\#dfdfdf\\r\\#bfbfbf\\a\\#9f9f9f\\z\\#7f7f7f\\i\\#6f6f6f\\l\\#5f5f5f\\i\\#4f4f4f\\a\\#3f3f3f\\n

-- uh.. sorry for any atrocious coding here lmao

local hook_event, get_id_from_behavior, audio_stream_play, incAir, swimming, cold, clampf, incHP, math_abs, underwater, metal =
hook_event, get_id_from_behavior, audio_stream_play, incAir, swimming, cold, clampf, incHP, math.abs, underwater, metal

local m = gMarioStates[0]
local incCounter, decCounter = 0, 0

hook_event(HOOK_ON_INTERACT, function(m, o, it)
    local x = get_id_from_behavior(o.behavior)
    if (m.healCounter > 0) then
        if x == id_bhvWaterAirBubble then
            m.healCounter = 0
            audio_stream_play(incFull, true, 1.7)
            incAir((maxAir / 8) * 5)
        end
        if x == (id_bhvMantaRayWaterRing or id_bhvJetStreamWaterRing) then
            m.healCounter = 0
            incAir(maxAir / 4)
        end
        if it == INTERACT_STAR_OR_KEY then
            air = maxAir
        end
    end
end)


hook_event(HOOK_BEFORE_PHYS_STEP, function(m)
    if m.playerIndex ~= 0 then return end
    if swimming() then
        if m.healCounter > 0 then
            if not cold() then
                incAir((maxAir / 32) * m.healCounter)
            end
            incCounter = incCounter + m.healCounter
            m.healCounter = 0
        end
        if m.hurtCounter > 0 then
            decCounter = decCounter + m.hurtCounter
            m.hurtCounter = 0
        end
    end
end)

hook_event(HOOK_MARIO_UPDATE, function(m)
    if m.playerIndex ~= 0 then return end
    if wait <= 31 then
        if m.action ~= ACT_BUBBLED then
            m.health = clampf(384 + (wait * 64), 256, 2176)
            wait = clampf(wait + 1, 0, 32)
            metalHP = 2176
            lastHP = 2176
        end
    else
        if m.playerIndex ~= 0 then return end
        totIncAir, totIncHP = (lastHP - m.health), (lastHP - m.health)
        wait = 32
        if incCounter > 0 then
            incHP(64)
            incCounter = incCounter - 1
        end
        if decCounter > 0 then
            incHP(-64)
            decCounter = decCounter - 1
        end
        if swimming() then
            if math.abs(totIncHP) < 64 and math.abs(totIncAir) < 64 then
                incAir(-totIncAir)
                incHP(totIncHP)
            end
            if air <= 0 then
                if cold() then totIncHP = math.abs(totIncHP - 2) end
                incHP(totIncHP * -4)
            end
        else
            if cold() then
                incAir(maxAir / 900)
            end
        end
        if cold() then
            maxAir = 480
        else
            maxAir = 1440
        end
        if not underwater() and not cold() then
            incAir(maxAir / 45)
        end
        if metal() then
            m.health = metalHP
            air = maxAir
        end
    end
    lastHP = m.health
end)

hook_event(HOOK_BEFORE_SET_MARIO_ACTION, function(m, a)
    if m.playerIndex ~= 0 then return end
    if a == ACT_WATER_PLUNGE and m.health < 384 then
        lastHP = 320
        m.health = 320
    end
    if a == ACT_DROWNING and wait <= 31 then
        return 1
    end
    if m.action == ACT_BUBBLED then
        wait = 0
    end
end)

hook_event(HOOK_ON_LEVEL_INIT, function()
    if m.playerIndex ~= 0 then return end
    air = maxAir
end)
