Collision = {}
function Collision.rect(r1, r2)
    if math.floor(r1.x1) > math.floor(r2.x2) or
        math.floor(r2.x1) > math.floor(r1.x2) or
        math.floor(r1.y1) > math.floor(r2.y2) or
        math.floor(r2.y1) > math.floor(r1.y2) then
        return false
    end
    return true
end

function Collision.get_rect_by_object(obj)
    return {
        x1 = obj.x + obj.hitbox.x1,
        x2 = obj.x + obj.hitbox.x2,
        y1 = obj.y + obj.hitbox.y1,
        y2 = obj.y + obj.hitbox.y2,
    }
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
--     return Collision.rect(r1, r2)
-- end
