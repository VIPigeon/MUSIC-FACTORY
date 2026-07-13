RestartDialog = {}

function RestartDialog:new()
    local object = {
        is_accepted = false,
    }
    setmetatable(object, self)
    return object
end

function RestartDialog:update()
    if key.ok() then
        set_normal_constants()
        self.is_accepted = true
    elseif key.speed_up_mode() and pmem(1)==1 then
        -- игрок уже побеждал и может включить speed-up
        set_speed_up_constants()
        self.is_accepted = true
    end
end

function RestartDialog:draw()
    local x = 7
    local y = 7
    local outline_width = 4
    local color_text = 4
    local color_outline = 2
    local size = 2
    -- TextWithOutline.print("You looks like dead beef", x, y, outline_width, color_text, color_outline, size)
    TextWithOutline.print("RESTART?", x, y, outline_width, color_text, color_outline, size)
    local shadow_color = 7
    local button_color = 3
    y = SCREEN_HEIGHT - outline_width*2 - 10
    TextWithOutline.print("Z", x, y+1, outline_width, shadow_color, shadow_color, size, true)
    TextWithOutline.print("Z", x, y, outline_width, color_text, button_color, size, true)
    if pmem(1)==1 then
        local shift = 21
        button_color = 2
        shadow_color = 1
        TextWithOutline.print("X", x+shift, y+1, outline_width, shadow_color, shadow_color, size, true)
        TextWithOutline.print("X", x+shift, y, outline_width, color_text, button_color, size, true)
    end
end


RestartDialog.__index = RestartDialog