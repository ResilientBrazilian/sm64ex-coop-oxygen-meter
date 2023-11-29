local math_abs, djui_hud_set_resolution, djui_hud_set_font, djui_hud_set_color, djui_hud_measure_text, string_format, math_ceil, djui_hud_set_rotation, djui_hud_render_texture =
   math.abs, djui_hud_set_resolution, djui_hud_set_font, djui_hud_set_color,
    djui_hud_measure_text, string.format, math.ceil, djui_hud_set_rotation, djui_hud_render_texture
function cold() return m.area.terrainType == TERRAIN_SNOW end

function incAir(x)
    if (x < 0 or air <= maxAir) and m.health > 255 then
        air = clampf(air + x, 0, maxAir)
    end
end

function incHP(x)
    if m.health > 255 then
        m.health = clampf(m.health + x, 255, 2176)
    end
end

function underwater() return m.pos.y < m.waterLevel - 140 end

function swimming() return m.action & ACT_GROUP_MASK == ACT_GROUP_SUBMERGED or (m.pos.y < m.waterLevel - 100) end

function if_then_else(cond, if_true, if_false)
    if cond then return if_true end
    return if_false
end

function metal()
    metalHP = m.health
    return m.flags == m.flags | MARIO_METAL_CAP
end

function lerpColor(r1, g1, b1, r2, g2, b2, percent)
    local result = { 100, 0, 0 }
    result[1] = clampf((r2 - r1) * percent + r1, 0, 255)
    result[2] = clampf((g2 - g1) * percent + g1, 0, 255)
    result[3] = clampf((b2 - b1) * percent + b1, 0, 255)
    return result
end

function renderTimer(color, amount, px, py)
    if math.abs(amount) > 2 ^ 31 then return end
    local txtScale = 0.175
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_MENU)
    djui_hud_set_color(color[1], color[2], color[3], 255)
    measure = djui_hud_measure_text(string.format("%.0f", math.ceil(amount))) * txtScale * 0.5
    djui_hud_print_text(string.format("%.0f", math.ceil(amount)), (px - measure) + (scale * 48), py + (scale * 4),
        txtScale)
end

function renderHalf(color, rotation, px, py, size)
    if not color[4] then color[4] = 255 end
    if size == nil then size = scale end
    djui_hud_set_color(color[1], color[2], color[3], color[4])
    djui_hud_set_rotation(rotation, 0.5, 0.5)
    djui_hud_render_texture(ringHalf, px, py, size, size)
end

function lerpNum(x, y, percent) return (y - x) * percent + x end
