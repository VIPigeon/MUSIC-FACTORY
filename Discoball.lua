
Laser = {}
function Laser:new(x, y, angle)
    local object = {
        x = x,
        y = y,
        angle = angle,

        attack_time = 0,
        status = 'off',
        -- 'red' -- для warning
        -- 'white' -- для prepare
        -- 'on'
    }
    setmetatable(object, self)
    return object
end

function Laser:get_line()
    local x2 = self.x + SCREEN_WIDTH * math.cos(self.angle)
    local y2 = self.y + SCREEN_WIDTH * math.sin(self.angle)

    return self.x, self.y, x2, y2
end

function Laser:update()
    if self.attack_time == 0 and self.status == 'on' then
        self.status = 'off'
    end

    self.attack_time = Time.tick(self.attack_time)
end

function Laser:draw()
    if self.status == 'off' then
        -- отрисовываем темно-красным в финале
        return
    end
    local x, y, x2, y2 = self:get_line()
    if self.status == 'white' then
        line(x, y, x2, y2, 4)
    elseif self.status == 'red' then
        line(x, y, x2, y2, 2)
    else -- 'on'
        line(x-1, y, x2-1, y2, 2)
        line(x+1, y, x2+1, y2, 2)
        line(x, y-1, x2, y2-1, 2)
        line(x, y+1, x2, y2+1, 2)
        line(x, y, x2, y2, 4)
    end

end

Laser.__index = Laser


Discoball = table.copy(Enemy)

function Discoball:new(x, y)
    local object = {
        x = x,
        y = y,
        r = Discoball.R,
        color = Discoball.COLOR,

        interbox = Discoball.INTERBOX,

        is_active = false,
        cost = Enemy.default_cost,

        status = 'release',

        sprite = {},

        laser_i = 1, -- активный лазер
        lasers = {
            Laser:new(x, y, 0),
            Laser:new(x, y, math.pi / 2),
            Laser:new(x, y, math.pi),
            Laser:new(x, y, math.pi * 3 / 2),
        },
        -- 👇 что только не сделаешь, чтобы не вызывать бинпоиск лишний раз
        laser_count = 4,
    }
    setmetatable(object, self)
    return object
end

function Discoball:move(x, y)
    self.x = x
    self.y = y
    self.lasers = {
        Laser:new(x, y, 0),
        Laser:new(x, y, math.pi / 2),
        Laser:new(x, y, math.pi),
        Laser:new(x, y, math.pi * 3 / 2),
    }
end

function Discoball:prepare()
    self.status = 'prepare'
    local laser = self.lasers[self.laser_i]
    laser.status = 'red'
end

function Discoball:attack()
    self.status = 'attack'
    local laser = self.lasers[self.laser_i]
    laser.status = 'on'
    laser.attack_time = Laser.ATTACK_TIME
end

function Discoball:release()
    self.status = 'release'

    self.laser_i = self.laser_i % self.laser_count + 1
end

function Discoball:update()
    if not self.is_active then
        self:activate_if_can()
    end

    for _, laser in ipairs(self.lasers) do
        laser:update()
        -- ...
        -- убиваем игрока лазером прямо здесь
    end
end

function Discoball:activate_if_can()
    if self.cost == 0 and not self.is_active then
        self.is_active = true
    end
end

function Discoball:draw()
    if not self.is_active then
        -- spr(400, )
        return
    end

    for _, laser in ipairs(self.lasers) do
        laser:draw()
    end
    -- circ(self.x, self.y, self.r, self.color)

end


Discoball.__index = Discoball