Player = {}


function Player:new(x, y)
    local object = {
        x = x,
        y = y,
        speed = Player.SPEED,

        -- i-фреймы
        i_time = 0,

        is_roll = false,
        roll_dx = 0,
        roll_dy = 0,

        -- последние ненулевые. НЕ ИСПОЛЬЗУЕТСЯ
        last_input_x = 0,
        last_input_y = 0,

        max_hp = Player.HP,
        hp = Player.HP,

        -- hitbox относителен
        hitbox = Player.HITBOX,
        sprite = table.copy(Player.sprite.stay),
        run_status = 'stay',
            -- run
        flip = 0,
    }

    setmetatable(object, self)
    return object
end

function Player:update()
    local input_x = 0
    local input_y = 0
    local is_roll = false
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
    if key.action() then
        is_roll = true
    end

    if self.is_roll then
        input_x = self.roll_dx
        input_y = self.roll_dy
        is_roll = false
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

    -- проверяем, что roll начался 🍱🍣😋
    if is_roll and (input_x ~= 0 or input_y ~= 0) then
        self.i_time = Player.ROLL_TIME
        self.is_roll = true
        -- if input_x == 0 and input_y == 0 then
        --     self.roll_dx = self.last_input_x
        --     self.roll_dy = self.last_input_y
        -- else
        self.roll_dx = input_x
        self.roll_dy = input_y
        self.speed = Player.ROLL_SPEED
        self.sprite = table.copy(Player.sprite.roll)
    end
    -- проверяем что roll закончился 🍱😔
    if self.i_time == 0 and self.is_roll then
        self.is_roll = false
        self.sprite = table.copy(Player.sprite.run)
        self.speed = Player.SPEED
    end

    if input_x ~= 0 or input_y ~= 0 then
        self.last_input_x = input_x
        self.last_input_y = input_y
    end
    self.i_time = Time.tick(self.i_time)
end

function Player:draw()
    local hp = self.hp
    local x = 0
    local dx = 9
    local y = 0
    for i = 1, math.floor(Player.HP / 2) do
        if hp == 1 then
            spr(HALF_HEART_SPRITE, x, y, C0, 1)
        elseif hp <= 0 then
            spr(EMPTY_HEART_SPRITE, x, y, C0, 1)
        else
            spr(FULL_HEART_SPRITE, x, y, C0, 1)
        end
        x = x + dx
        hp = hp - 2
    end

    spr(self.sprite[self.sprite.i].id, self.x, self.y, C0,1, self.flip)
end

function Player:hurt()
    if self.i_time > 0 then
        return
    end
    self.i_time = Player.I_TIME
    self.hp = self.hp - 1
end

Player.__index = Player
