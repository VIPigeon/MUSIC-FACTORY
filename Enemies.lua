
Enemy = {}
function Enemy:draw()
    spr(self.sprite[self.sprite.i].id, self.x, self.y, C0,1)
end
function Enemy:update()
    Anime.tick(self.sprite)
end
-- function Enemy:update()
-- end
-- function Enemy:draw()
-- end
-- function Enemy:attack()
-- end


PistonEnemy = table.copy(Enemy)
function PistonEnemy:new(x, y)
    local object = {
        x = x,
        y = y,
        sprite = table.copy(PistonEnemy.sprite.release),
        hitbox = PistonEnemy.HITBOX,
        activation_hitbox = PistonEnemy.HITBOX,
    }
    setmetatable(object, self)
    return object
end

function PistonEnemy:prepare()
    self.sprite = table.copy(PistonEnemy.sprite.prepare)
end

function PistonEnemy:attack()
    self.sprite = table.copy(PistonEnemy.sprite.attack)

    local COUNT_BULLETS = 5
    local SECTOR = 2*math.pi / COUNT_BULLETS
    for i = 1, COUNT_BULLETS do
        local bullet = Bullet:new(self.x+3, self.y+5)
        local angle = math.random() * SECTOR + (i-1)*SECTOR
        bullet.dx = math.cos(angle)
        bullet.dy = math.sin(angle)
        table.insert(game.bullets, bullet)
    end
end

function PistonEnemy:release()
    self.sprite = table.copy(PistonEnemy.sprite.release)
end

function PistonEnemy:warning()
    self.sprite = table.copy(PistonEnemy.sprite.warning)
end

PistonEnemy.__index = PistonEnemy
