Player = {}


function Player:new(x, y)
    local object = {
        x = x,
        y = y,
        speed = Player.SPEED,

        -- i-фреймы
        i_time = 0,

        is_roll = false,
        roll_time = 0,
        roll_dx = 0,
        roll_dy = 0,
        roll_cooldown = 0,  -- перезарядка переката
        roll_buffer = false, -- QoL

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

        -- параметры для оплаты
        -- см. game.update()
        payment_t = 0,
        payment_T = 0,
    }

    setmetatable(object, self)
    return object
end

function Player:move_as_possible(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy

    -- смещения под картинку игрока
    -- если изменить внешность игрока, то я умираю
    local x1 = self.hitbox.x1 - 1
    local x2 = self.hitbox.x2 + 2
    local y1 = self.hitbox.y1 - 2
    local y2 = self.hitbox.y2 + 3

    -- Горизонталь
    if self.x + x1 < 0 then
        self.x = -x1
    elseif self.x + x2 > SCREEN_WIDTH then
        self.x = SCREEN_WIDTH - x2
    end

    -- Вертикаль
    if self.y + y1 < 0 then
        self.y = -y1
    elseif self.y + y2 > SCREEN_HEIGHT then
        self.y = SCREEN_HEIGHT - y2
    end
    -- local hb1 = Collision.get_hitbox_by_object(self)
    -- hb1 = Collision.get_hitbox_by_object(self)




    -- for _, e in pairs(game.enemies) do
    --     local hb2 = Collision.get_hitbox_by_object(e)
    --     if Collision.check(hb1, hb2) then
    --         self.y = self.y - dy
    --         break
    --     end
    -- end
end

-- function Player( ... )
--     -- body
-- end

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

    self:move_as_possible(
        input_x * self.speed * k * Time.dt(),
        input_y * self.speed * k * Time.dt()
    )

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

    -- проверяем, что roll начался 🍱🍣😋
    if (is_roll or self.roll_buffer) and (input_x ~= 0 or input_y ~= 0) then
        if self.roll_cooldown > 0 then
            self.roll_buffer = (self.roll_cooldown < self.ROLL_BUFFER)
        else
            self.roll_buffer = false
            -- self.i_time = Player.ROLL_TIME
            self.roll_time = Player.ROLL_TIME
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
    end
    -- проверяем что roll закончился 🍱😔
    if self.roll_time == 0 and self.is_roll then
        self.is_roll = false
        self.sprite = table.copy(Player.sprite.run)
        self.speed = Player.SPEED
        self.roll_cooldown = Player.ROLL_COOLDOWN
    end

    if input_x ~= 0 or input_y ~= 0 then
        self.last_input_x = input_x
        self.last_input_y = input_y
    end
    Anime.tick(self.sprite)
    self.i_time = Time.tick(self.i_time)
    self.roll_time = Time.tick(self.roll_time)
    self.roll_cooldown = Time.tick(self.roll_cooldown)
    self.payment_t = Time.tick(self.payment_t)
end

function Player:draw()
    local hp = self.hp

    local x = 2
    local dx = 9
    local y = 2
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
    if self.i_time > 0 or self.roll_time > 0 then
        return
    end
    self.i_time = Player.I_TIME
    self.hp = self.hp - 1
end

function Player:pay(object)
    -- тикает в апдейте игрока
    if object.cost == 0 then
        return
    end
    if self.payment_t == 0 then
        self.payment_T = self.payment_T * Player.PAYMENT_ACC
        self.payment_t = self.payment_T
        object.cost = object.cost - 1
        game.money = game.money - 1
    end
end

Player.__index = Player
