WinScreen = {}

function WinScreen:new()
    local object = {
        is_accepted = false,
    }
    setmetatable(object, self)
    return object
end

function WinScreen:update()
    if key.ok() then
        set_normal_constants()
        self.is_accepted = true
    elseif key.speed_up_mode() then
        set_speed_up_constants()
        self.is_accepted = true
    end
end

function WinScreen:draw()
    local x = 4
    local y = 4
    local dy = 8
    local outline_width = 1
    local color = 4
    -- local color_outline = C0
    local size = 1
    local shadow_color = 6

    for _, line in ipairs(WinScreen.TEXT) do
        local c = color
        local sc = shadow_color
        if line == WinScreen.MY_TG then
            c = 3
            sc = 7
        elseif line == WinScreen.SPEED_UP then
            c = 2
            sc = 1
        end
        print(line, x, y+1, sc)
        print(line, x, y, c)
        if line == WinScreen.YOUR_TIME then
            local text = math.floor(game.time/60)..' : '..math.floor(game.time%60)..'.'..math.floor(game.time%60*100%100)
            c = GOLD
            sc = DARK_GOLD
            print(text, x+#WinScreen.YOUR_TIME*6, y+1, sc)
            print(text, x+#WinScreen.YOUR_TIME*6, y, c)
        end
        y = y + dy
    end
    -- TextWithOutline.print("Z", x, y+1, outline_width, shadow_color, shadow_color, size, true)
    -- TextWithOutline.print("Z", x, y, outline_width, color_text, button_color, size, true)
end


WinScreen.__index = WinScreen