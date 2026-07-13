
-- генерация уровня
Generation = {}

function Generation.is_collide(e1, e2)
    local pupa = Collision.get_interbox_by_object(e1)
    local lupa = Collision.get_interbox_by_object(e2)
    return Collision.check(pupa, lupa)
end

function Generation.rect(e)
    -- возвращает прямоугольник в формате {x1, y1, x2, y2}
    -- где x1 y1 -- левый верхний угол
    -- где x2 y2 -- правый нижний угол
    return Collision.get_interbox_by_object(e)
end

function Generation.place(e, x, y)
    e.x = x - e.interbox.x1
    e.y = y - e.interbox.y1
    -- body
end

-- главная функция, расставляющая объекты
function Generation.get_places(k, w, h)
    w = w or 3
    h = h or 4

    local WIDTH = 30
    local HEIGHT = 17

    local static_objects = {
        {x = 0,  y = 0, w = 4, h = 3},
        {x = 14, y = 7, w = 3, h = 3},
        {x = 0,  y = 26, w = 4, h = 3},
    }

    local result = {}

    local function intersects(a, b)
        return not (
            a.x + a.w <= b.x or
            b.x + b.w <= a.x or
            a.y + a.h <= b.y or
            b.y + b.h <= a.y
        )
    end

    -- Все возможные позиции
    local positions = {}
    for y = 0, HEIGHT - h do
        for x = 0, WIDTH - w do
            table.insert(positions, {x = x, y = y})
        end
    end

    -- Fisher-Yates shuffle
    for i = #positions, 2, -1 do
        local j = math.random(i)
        positions[i], positions[j] = positions[j], positions[i]
    end

    -- Проверяем позиции в случайном порядке
    for _, pos in ipairs(positions) do
        local rect = {
            x = pos.x,
            y = pos.y,
            w = w,
            h = h,
        }

        local ok = true

        for _, obj in ipairs(static_objects) do
            if intersects(rect, obj) then
                ok = false
                break
            end
        end

        if ok then
            for _, obj in ipairs(result) do
                if intersects(rect, obj) then
                    ok = false
                    break
                end
            end
        end

        if ok then
            table.insert(result, rect)
            if #result == k then
                return result
            end
        end
    end

    -- Если места не хватило
    return Generation.get_places(k, w, h)
end

function Generation.sort_by_center(objects)
    local WIDTH = 30
    local HEIGHT = 17

    local cx = WIDTH / 2
    local cy = HEIGHT / 2

    table.sort(objects, function(a, b)
        local ax = a.x + a.w / 2
        local ay = a.y + a.h / 2
        local bx = b.x + b.w / 2
        local by = b.y + b.h / 2

        local da = (ax - cx)^2 + (ay - cy)^2
        local db = (bx - cx)^2 + (by - cy)^2

        return da < db
    end)

    -- return objects
    -- ☝️ нахера козе баян
end
