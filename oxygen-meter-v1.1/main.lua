-- name: Oxygen Meter \\#00ffff\\v1.1
-- description: Separates the oxygen/drowning function from the power meter into its own meter. The player starts taking damage once the oxygen meter runs out.\n\\#888888\\This does not apply to toxic gas. The power meter may also be slightly unstable..\n\n\\#ffffff\\> mod by \\#3f3f3f\\R\\#4f4f4f\\e\\#5f5f5f\\s\\#6f6f6f\\i\\#7f7f7f\\l\\#9f9f9f\\i\\#bfbfbf\\e\\#dfdfdf\\n\\#ffffff\\t\\#ffffff\\B\\#dfdfdf\\r\\#bfbfbf\\a\\#9f9f9f\\z\\#7f7f7f\\i\\#6f6f6f\\l\\#5f5f5f\\i\\#4f4f4f\\a\\#3f3f3f\\n

-- uh.. sorry for any atrocious coding here lmao

-----------------------------------------v VARIABLES v-----------------------------------------
local m = gMarioStates[0]

local lastHP = 0
local metalHP = 0

local incFull = audio_stream_load('galaxy_IncreaseFull.mp3')
local beep = audio_stream_load('beep.mp3')


local ringEmpty = get_texture_info('Ring_Empty')
local ringHalf = get_texture_info('Ring_Half')

local wheel = 0

local maxAir = 1410
local air = maxAir
local tick = 0
local wait = 32
local size = 0

local incCounter, decCounter = 0, 0
local totIncAir, totIncHP = 0, 0

-----------------------------------------v FUNCTIONS v-----------------------------------------

local function cold() return m.area.terrainType == TERRAIN_SNOW end

local function incAir(x)
    if m.playerIndex ~= 0 then return end
    if (x < 0 or air <= maxAir) and m.health > 255 then
        air = clampf(air + x, 0, maxAir)
    end
end

local function incHP(x)
    if m.playerIndex ~= 0 then return end
    if m.health > 255 then
        m.health = clampf(m.health + x, 255, 2176)
    end
end

local function underwater()
    if m.playerIndex ~= 0 then return end
    return m.pos.y < m.waterLevel - 140
end

local function swimming()
    if m.playerIndex ~= 0 then return end
    return m.action & ACT_GROUP_MASK == ACT_GROUP_SUBMERGED or
        (m.pos.y < m.waterLevel - 100)
end

local function metal()
    if m.playerIndex ~= 0 then return end
    metalHP = m.health
    return m.flags == m.flags | MARIO_METAL_CAP
end

local function lerpColor(r1, g1, b1, r2, g2, b2, percent)
    local result = { 100, 0, 0 }
    result[1] = clampf((r2 - r1) * percent + r1, 0, 255)
    result[2] = clampf((g2 - g1) * percent + g1, 0, 255)
    result[3] = clampf((b2 - b1) * percent + b1, 0, 255)
    return result
end

local function renderHalf(color, amount, px, py)
    djui_hud_set_color(color[1], color[2], color[3], 255)
    djui_hud_set_rotation(amount, 0.5, 0.5)
    djui_hud_render_texture(ringHalf, px, py, size, size)
end

function lerpNum(x, y, percent) return (y - x) * percent + x end

-----------------------------------------v SCRIPT v-----------------------------------------


hook_event(HOOK_ON_HUD_RENDER, function()
    tick = tick + 1
    size = clampf(0.2 - (gLakituState.focusDistance / 15000), 0.025, 0.75)
    local out = { x = 0, y = 0, z = 0 }
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_world_pos_to_screen_pos(m.pos, out)

    local pX = clampf(out.x - 0, 0, djui_hud_get_screen_height() - 19.2) + (size * 100)
    local pY = djui_hud_get_screen_height() / 2

    if air > 0 then
        wheel = lerpNum(wheel, clampf(2 ^ 16 - ((air / maxAir) * 2 ^ 16), 0, math.huge), 0.3)
    elseif air >= maxAir then
        wheel = 0
    else
        wheel = 2 ^ 16
    end

    if is_game_paused() or m.health <= 255 or m.action == ACT_CAUGHT_IN_WHIRLPOOL or m.pos.y > m.waterLevel + 1000 then return end

    if wheel > 16 then
        if air <= 0 and tick / 2 == math.floor(tick / 2) then
            djui_hud_set_color(255, 0, 0, 255)
        else
            djui_hud_set_color(0, 0, 0, 255)
        end
        djui_hud_render_texture(ringEmpty, pX, pY, size, size)

        if wheel < 2 ^ 15 then
            local color = lerpColor(255, 255, 0, 0, 255, 0, (air / maxAir) * 2 - 1)
            if cold() then
                color = lerpColor(0, 255, 255, 0, 255, 0, (air / maxAir) * 2 - 1)
            end
            renderHalf(color, wheel + 2 ^ 15, pX, pY)
            renderHalf(color, 0, pX, pY)
        else
            if air <= 0 then
                if tick / 2 == math.floor(tick / 2) then
                    audio_stream_play(beep, true, 2.2)
                end
            else
                local color = lerpColor(255, 0, 0, 255, 255, 0, (air / maxAir) * 2)
                if cold() then
                    color = lerpColor(255, 255, 255, 0, 255, 255, (air / maxAir) * 2)
                end
                renderHalf(color, wheel + 2 ^ 15, pX, pY)
                renderHalf({ 0, 0, 0 }, 2 ^ 15, pX, pY)
            end
        end
    end
end)

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
    if cold() then
        maxAir = 480
    else
        maxAir = 1410
    end
    air = maxAir
end)
