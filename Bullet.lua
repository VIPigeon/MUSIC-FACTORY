
Bullet = {}

function Bullet:new(x, y)
    local object = {
        x = x,
        y = y,
        -- direction x. А вы о чем подумали? 🤨
        dx = 0,
        dy = 0,
        hitbox = {x1=0, y1=0, x2=2, y2=2},
        -- speed = Bullet.speed,
    }
    setmetatable(object, self)
    return object;
end

function Bullet:draw(color)
    local c1 = 2
    local c2 = 4
    if color ~= nil then
        c1 = color
        c2 = color
    end
    rect(self.x, self.y, 3, 3, c1)
    rect(self.x+1, self.y+1, 1, 1, c2)
end

function Bullet:update()
    self.x = self.x + self.dx * Bullet.speed * Time.dt()
    self.y = self.y + self.dy * Bullet.speed * Time.dt()
end

Bullet.__index = Bullet
