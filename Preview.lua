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
    local x = 7
    local y = 7
    local outline_width = 4
    local color_text = 6
    local color_outline = 5
    local size = 2
    -- TextWithOutline.print("You looks like dead beef", x, y, outline_width, color_text, color_outline, size)
    TextWithOutline.print("MUSIC FACTORY", x, y, outline_width, color_text, color_outline, size)
    local shadow_color = 7
    local button_color = 3
    y = SCREEN_HEIGHT - outline_width*2 - 10
    TextWithOutline.print("Z", x, y+1, outline_width, shadow_color, shadow_color, size, true)
    TextWithOutline.print("Z", x, y, outline_width, color_text, button_color, size, true)
end


RestartDialog.__index = RestartDialog
