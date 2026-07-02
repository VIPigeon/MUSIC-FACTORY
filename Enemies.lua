
Enemy = {}
-- function Enemy:draw()
--     spr(self.sprite[self.sprite.i].id, self.x, self.y, C0,1)
-- end
-- function Enemy:update()
--     Anime.tick(self.sprite)
-- end
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
        sprite = table.copy(PistonEnemy.sprite.inactive),
        hitbox = PistonEnemy.HITBOX,
        interbox = PistonEnemy.INTERBOX,

        is_active = false,
        cost = Enemy.default_cost,
    }
    setmetatable(object, self)
    return object
end

function PistonEnemy:prepare()
    if not self.is_active then
        return
    end

    self.sprite = table.copy(PistonEnemy.sprite.prepare)
end

function PistonEnemy:attack()
    -- if not self.is_active then
    --     return
    -- end

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
    -- if not self.is_active then
    --     return
    -- end

    self.sprite = table.copy(PistonEnemy.sprite.release)
end

function PistonEnemy:warning()
    -- if not self.is_active then
    --     return
    -- end

    self.sprite = table.copy(PistonEnemy.sprite.warning)
end

function PistonEnemy:draw()
    if not self.is_active then
        print(self.cost, self.x - 1, self.y + 9, 5, false,1, false)
        Collision.draw_box(Collision.get_interbox_by_object(self))
    end

    spr(self.sprite[self.sprite.i].id, self.x, self.y, C0,1)
end

function PistonEnemy:update()
    if not self.is_active then
        self:activate_if_can()
    else
        Anime.tick(self.sprite)
    end

end

function PistonEnemy:activate_if_can()
    if self.cost == 0 and not self.is_active then
        self.is_active = true
        self.sprite = PistonEnemy.sprite.release
    end
end

PistonEnemy.__index = PistonEnemy


CircleEnemy = table.copy(Enemy)
function CircleEnemy:new(x, y)
    local object = {
        x = x,
        y = y,
        hitbox = CircleEnemy.HITBOX,
        interbox = CircleEnemy.INTERBOX,

        -- пуля не апдейтится и не отрисовывается,
        -- так как не находится в списке пуль
        chambered_bullet = Bullet:new(x-1, y-1),
        -- -1 — костыль для пули 3×3

        is_active = false,
        cost = Enemy.default_cost,

        -- вместо спрайта
        status = 'release',
        -- 'warning'
        -- 'prepare'
        -- 'attack'
        -- 'release'
        is_bullet_shot = false,
    }
    setmetatable(object, self)
    return object
end

function CircleEnemy:prepare()
    -- if not self.is_active then
    --     return
    -- end
    self.status = 'prepare'
end

function CircleEnemy:attack()
    -- if not self.is_active then
    --     return
    -- end
    self.status = 'attack'
end

function CircleEnemy:release()
    -- if not self.is_active then
    --     return
    -- end
    self.status = 'release'
end

function CircleEnemy:warning()
    -- if not self.is_active then
    --     return
    -- end
    self.status = 'warning'
end


function CircleEnemy:draw()
    if not self.is_active then
        Collision.draw_box(Collision.get_interbox_by_object(self))
        TextWithOutline.print(self.cost, self.x - self.interbox.r + 4, self.y - 1 + self.interbox.r, 2, 5,C0, 1, true)

        Collision.draw_box(Collision.get_hitbox_by_object(self), 5)
        self.chambered_bullet:draw(6)
        return
    end

    Collision.draw_box(Collision.get_hitbox_by_object(self), 4)

    if self.status == 'release' then
        self.chambered_bullet:draw(1)
    elseif self.status ~= 'attack' then
        self.chambered_bullet:draw()
    end

end

function CircleEnemy:aimToPlayer()
    local x = self.x
    local y = self.y
    local px, py = Collision.get_box_center(Collision.get_hitbox_by_object(game.player))

    local dx = px - x
    local dy = py - y

    local length = math.sqrt(dx * dx + dy * dy)

    if length == 0 then
        return 0, 0
    end

    return dx / length, dy / length
end

function CircleEnemy:update()
    if not self.is_active then
        self:activate_if_can()
    end

    if self.status == 'prepare' then
        local dx, dy = self:aimToPlayer()
        self.chambered_bullet.x = self.x-1 - CircleEnemy.PULLBACK_DISTANCE * dx
        self.chambered_bullet.y = self.y-1 - CircleEnemy.PULLBACK_DISTANCE * dy
    elseif self.status == 'attack' and self.is_bullet_shot then
        local dx, dy = self:aimToPlayer()

        self.chambered_bullet.x = self.x-1-- + CircleEnemy.PULLBACK_DISTANCE * dx
        self.chambered_bullet.y = self.y-1-- + CircleEnemy.PULLBACK_DISTANCE * dy


        self.chambered_bullet.dx = dx
        self.chambered_bullet.dy = dy
        table.insert(game.bullets, self.chambered_bullet)
        self.chambered_bullet = Bullet:new(self.x-1, self.y-1)
        self.is_bullet_shot = false
    elseif self.status == 'release' then
        self.is_bullet_shot = true
    --     self.chambered_bullet = Bullet:new(self.x-1, self.y-1)
    end
end

function CircleEnemy:activate_if_can()
    if self.cost == 0 and not self.is_active then
        self.is_active = true
    end
end

CircleEnemy.__index = CircleEnemy

