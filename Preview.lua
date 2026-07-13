-- это стартовый экран, но мне уже лень переименовывать

Preview = {}

function Preview:new()
    local object = {
        is_accepted = false,
    }
    setmetatable(object, self)
    return object
end

function Preview:update()
    if key.ok() then
        self.is_accepted = true
    end
end

function Preview:draw()
    local x = 4
    local y = 4
    local dy = 8
    local outline_width = 1
    local color = 4
    -- local color_outline = C0
    local size = 1
    local shadow_color = 6

    for _, line in ipairs(Preview.TEXT) do
        local c = color
        local sc = shadow_color
        if line == Preview.SPEND or line == Preview.EARN then
            c = GOLD
            sc = DARK_GOLD
        end
        print(line, x, y+1, sc)
        print(line, x, y, c)
        y = y + dy
    end
    -- TextWithOutline.print("You looks like dead beef", x, y, outline_width, color_text, color_outline, size)
    -- TextWithOutline.print("RESTART?", x, y, outline_width, color_text, color_outline, size, true)
    -- local button_color = 3
    -- y = SCREEN_HEIGHT - outline_width*2 - 10
    -- TextWithOutline.print("Z", x, y+1, outline_width, shadow_color, shadow_color, size, true)
    -- TextWithOutline.print("Z", x, y, outline_width, color_text, button_color, size, true)
end


Preview.__index = Preview
