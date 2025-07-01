--- Text based on your game resolution
---@param content string @ Text content (example: "hello world")
---@param size number? @ Text size (default: 1)
---@param color rgba? @ rgba(r, g, b, a)
---@param font DjuiFontType? @ rgba(r, g, b, a)
---@param x number? @ X coord, if it is nil, it is centered
---@param y number? @ Y coord, if it is nil, it is centered
function text(content, size, color, font, x, y)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    size = size or 1
    color = color or rgba(255, 255, 255, 255)
    font = font or FONT_MENU

    djui_hud_set_font(font)

    local text_w = djui_hud_measure_text(content) * size
    local text_h = size*64

    -- if x/y are nil, center
    x = x or (djui_hud_get_screen_width() - text_w) / 2
    y = y or (djui_hud_get_screen_height() - text_h) / 2

    djui_hud_set_color(color.r, color.g, color.b, color.a)
    djui_hud_print_text(content, x, y, size)
end

--- Text based on the N64 resolution
---@param content string @ Text content (example: "hello world")
---@param size number? @ Text size (default: 1)
---@param color rgba? @ rgba(r, g, b, a)
---@param font DjuiFontType? @ rgba(r, g, b, a)
---@param x number? @ X coord, if it is nil, it is centered
---@param y number? @ Y coord, if it is nil, it is centered
function text64(content, size, color, font, x, y)
    djui_hud_set_resolution(RESOLUTION_N64)
    size = size or 1
    color = color or rgba(255, 255, 255, 255)
    font = font or FONT_MENU

    djui_hud_set_font(font)

    local text_w = djui_hud_measure_text(content) * size
    local text_h = size*64

    -- if x/y are nil, center
    x = x or (djui_hud_get_screen_width() - text_w) / 2
    y = y or (djui_hud_get_screen_height() - text_h) / 2

    djui_hud_set_color(color.r, color.g, color.b, color.a)
    djui_hud_print_text(content, x, y, size)
end

--- Texture based on your game resolution
---@param texture TextureInfo @ Texture to render
---@param original_dims Vec3f? @ Original texture dimensions in pixels (default: 16x16)
---@param size number? @ Texture scale (default: 1)
---@param x number? @ X coord, if it is nil, it is centered
---@param y number? @ Y coord, if it is nil, it is centered
---@param color rgba? @ Texture color (default: rgba(255, 255, 255, 255))
function texture(texture, original_dims, size, x, y, color)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    size = size or 1
    original_dims = original_dims or vec3f_new(16, 16)
    color = color or rgba(255, 255, 255, 255)

    -- if x/y are nil, center
    x = x or (djui_hud_get_screen_width() - (original_dims.x * size)) / 2
    y = y or (djui_hud_get_screen_height() - (original_dims.y * size)) / 2

    djui_hud_set_color(color.r, color.g, color.b, color.a)
    djui_hud_render_texture(texture, x, y, size, size)
end

--- Texture based on the N64 resolution
---@param texture TextureInfo @ Texture to render
---@param original_dims Vec3f? @ Original texture dimensions in pixels (default: 16x16)
---@param size number? @ Texture scale (default: 1)
---@param x number? @ X coord, if it is nil, it is centered
---@param y number? @ Y coord, if it is nil, it is centered
---@param color rgba? @ Texture color (default: rgba(255, 255, 255, 255))
function texture64(texture, original_dims, size, x, y, color)
    djui_hud_set_resolution(RESOLUTION_N64)
    size = size or 1
    original_dims = original_dims or vec3f_new(16, 16)
    color = color or rgba(255, 255, 255, 255)

    -- if x/y are nil, center
    x = x or (djui_hud_get_screen_width() - (original_dims.x * size)) / 2
    y = y or (djui_hud_get_screen_height() - (original_dims.y * size)) / 2

    djui_hud_set_color(color.r, color.g, color.b, color.a)
    djui_hud_render_texture(texture, x, y, size, size)
end

---Render a power meter
---@param x any?
---@param y any?
---@param width any?
---@param height any?
---@param color rgba?
function power_meter(x, y, width, height, color)
    djui_hud_set_resolution(RESOLUTION_N64)
    width = width or 48
    height = height or 48
    color = color or rgba(255, 255, 255, 255)

    x = x or (djui_hud_get_screen_width() - width) / 2
    y = y or (djui_hud_get_screen_height() - height) / 2

    djui_hud_set_color(color.r, color.g, color.b, color.a)
    hud_render_power_meter(gMarioStates[0].health, x, y, width, height)
end
