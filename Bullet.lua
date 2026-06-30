
Bullet = {}

function Bullet:new(x, y)
    local object = {
        x = x,
        y = y,
        -- direction x. А вы о чем подумали? 🤨
        dx = 0,
        dy = 0,
        hitbox = {x1=0, y1=0, x2=1, y2=1},
        -- speed = Bullet.speed,
    }
    setmetatable(object, self)
    return object;
end

function Bullet:draw()
    rect(self.x, self.y, 2, 2, 2)
end

function Bullet:update()
    self.x = self.x + self.dx * Bullet.speed * Time.dt()
    self.y = self.y + self.dy * Bullet.speed * Time.dt()
end

Bullet.__index = Bullet
