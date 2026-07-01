Collision = {}

function Collision._circle_and_rect(c, r)
    local nearestX = math.min(math.max(c.x, r.x1), r.x2)
    local nearestY = math.min(math.max(c.y, r.y1), r.y2)

    local dx = c.x - nearestX
    local dy = c.y - nearestY

    return dx * dx + dy * dy <= c.r * c.r
end

function Collision.check(r1, r2)
    if r1.is_circle and not r2.is_circle then
        return Collision._circle_and_rect(r1, r2)
    elseif r2.is_circle and not r1.is_circle then
        return Collision._circle_and_rect(r2, r1)
    end

    if math.floor(r1.x1) > math.floor(r2.x2) or
        math.floor(r2.x1) > math.floor(r1.x2) or
        math.floor(r1.y1) > math.floor(r2.y2) or
        math.floor(r2.y1) > math.floor(r1.y2) then
        return false
    end
    return true
end

function Collision.draw_box(box, c)
    if c == nil then
        c = 6
    end

    if box.is_circle then
        circb(box.x, box.y, box.r, c)
        return
    end
    rectb(box.x1, box.y1, box.x2-box.x1+1, box.y2-box.y1+1, c)
end

function Collision.get_hitbox_by_object(obj)
    local res = table.copy(obj.hitbox)
    if res.is_circle then
        res.x = res.x + obj.x
        res.y = res.y + obj.y
        return res
    end
    res.x1 = obj.x + res.x1
    res.x2 = obj.x + res.x2
    res.y1 = obj.y + res.y1
    res.y2 = obj.y + res.y2
    return res
end

function Collision.get_box_center(box)
    if box.is_circle then
        return box.x, box.y
    end
    return
        math.floor((box.x1 + box.x2 + 1) / 2),
        math.floor((box.y1 + box.y2 + 1) / 2)
end

function Collision.get_interbox_by_object(obj)
    local res = table.copy(obj.interbox)
    if res.is_circle then
        res.x = res.x + obj.x
        res.y = res.y + obj.y
        return res
    end
    res.x1 = obj.x + res.x1
    res.x2 = obj.x + res.x2
    res.y1 = obj.y + res.y1
    res.y2 = obj.y + res.y2
    return res
end

-- function Collision.lazy_rect(obj1, obj2)
--     local r1 = {
--         x1 = obj1.x + obj1.hitbox.x1,
--         x2 = obj1.x + obj1.hitbox.x2,
--         y1 = obj1.y + obj1.hitbox.y1,
--         y2 = obj1.y + obj1.hitbox.y2,
--     }
--     local r2 = {
--         x1 = obj2.x + obj2.hitbox.x1,
--         x2 = obj2.x + obj2.hitbox.x2,
--         y1 = obj2.y + obj2.hitbox.y1,
--         y2 = obj2.y + obj2.hitbox.y2,
--     }
--     return Collision.check(r1, r2)
-- end
