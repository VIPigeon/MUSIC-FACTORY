
Coin = {}
function Coin:new(x, y, is_static)
    local object = {
        x = x,
        y = y,
    }
    if is_static then
        object.animation = Coin.sprite.static
    else
        object.animation = table.copy(Coin.sprite.flip)
    end
    setmetatable(object, self)
    return object
end

function Coin:update()
    Anime.tick(self.animation)
end

function Coin:draw()
    local i = self.animation[self.animation.i].id
    local x = self.x
    local y = self.y
    -- trace(i..' '..x..' '..y)
    spr(i, x, y, C0)
end

Coin.__index = Coin
