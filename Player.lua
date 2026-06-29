Player = {}


function Player:new(x, y)
    local object = {
        x = x,
        y = y,
        speed = 50,

        sprite = table.copy(Player.sprite.stay),
        run_status = 'stay',
        flip = 0,
    }
    setmetatable(object, self)
    return object
end

function Player:update()
    local input_x = 0
    local input_y = 0
    if key.left() then
        input_x = input_x - 1
    end
    if key.right() then
        input_x = input_x + 1
    end
    if key.up() then
        input_y = input_y - 1
    end
    if key.down() then
        input_y = input_y + 1
    end

    local k = 1
    if input_x*input_y ~= 0 then
        k = 1 / math.sqrt(2)
    end

    self.x = self.x + input_x * self.speed * k * Time.dt()
    self.y = self.y + input_y * self.speed * k * Time.dt()

    if input_x < 0 then
        self.flip = 1
    elseif input_x > 0 then
        self.flip = 0
    end

    if input_x ~= 0 or input_y ~= 0 then
        if self.run_status == 'stay' then
            self.run_status = 'run'
            self.sprite = table.copy(Player.sprite.run)
        end
    else
        if self.run_status == 'run' then
            self.run_status = 'stay'
            self.sprite = table.copy(Player.sprite.stay)
        end
    end
    Anime.tick(self.sprite)
end

function Player:draw()
    spr(self.sprite[self.sprite.i].id, self.x, self.y, C0,1, self.flip)
end

Player.__index = Player
