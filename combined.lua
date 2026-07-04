
C0 = 0

-- BEGIN Math.lua

function math.isObtuse(x1,y1,x2,y2,x3,y3)
    return (x1-x2)*(x3-x2)+(y1-y2)*(y3-y2)>0
end


function math.fence(x, left, right)
    if x < left then
        return left
    end
    if x > right then
        return right
    end
    return x
end


function math.round(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

function math.sqr(x)
    return x * x
end

function math.vecLength(vec)
    return math.sqrt(math.sqr(vec.x) + math.sqr(vec.y))
end

function math.vecNormalize(vec)
    local len = math.vecLength(vec)
    return {x = vec.x / len, y = vec.y / len}
end

function math.sign(x)
    if x<0 then
        return -1
    end
    if x>0 then
        return 1
    end
    return 0
end

function math.distance(x1, y1, x2, y2)
    -- возвращает квадрат расстояния между точками
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

function math.sq_distance(x1, y1, x2, y2)
    -- возвращает квадрат расстояния между точками
    return math.abs(x1 - x2)^2 + math.abs(y1 - y2)^2
end


function math.sq_point_ortsegment_distance(x, y, x1, y1, x2, y2)
    -- отрезок ортогональный
    if (x == x1 and x == x2) or (y == y1 and y == y2) then
        return 0
    end
    if x1 <= x and x <= x2 then
        return math.min(math.sq_distance(x, y, x1, y1), math.sq_distance(x, y, x2, y2), math.sq_distance(x, y, x, y1))
    end
    if y1 <= y and y <= y2 then
        return math.min(math.sq_distance(x, y, x1, y1), math.sq_distance(x, y, x2, y2), math.sq_distance(x, y, x1, y))
    end
    return math.min(math.sq_distance(x, y, x1, y1), math.sq_distance(x, y, x2, y2))
end


function math.inRangeNotIncl(num, leftBoarder, rightBoarder)
    return num > leftBoarder and num < rightBoarder
end

function math.inRangeIncl(num, leftBoarder, rightBoarder)
    return num >= leftBoarder and num <= rightBoarder
end

-- function math.sq_distance( ... )
--     -- body
-- end


-- END Math.lua
-- BEGIN Table.lua
function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function table.equals(t1, t2)
    for i, value in ipairs(t1) do
        if value ~= t2[i] then
            return false
        end
    end
    return true
end

function table.concatTable(destination, source)
    for _, element in ipairs(source) do
        table.insert(destination, element)
    end
end

function table.contains_table(t, element)
    for _, value in pairs(t) do
        if table.equals(value, element) then
            return true
        end
    end
    return false
end

function table.contains(t, element)
    for _, value in pairs(t) do
        if value == element then
            return true
        end
    end
    return false
end

function table.removeElement(t, element)
    ind = 0
    for i, value in ipairs(t) do
        if value == element then
            ind = i
            break
        end
    end

    if ind > 0 and ind <= #t then -- 😁😁😁😁 Тут был '<' я его полтора часа исправлял на '<='
        table.remove(t, ind)
    end
end

function table.removeElements(t, removed)
    for i, value in ipairs(t) do
        if table.contains(removed, value) then
            table.remove(t, i)
        end
    end
end

function table.reversed(t)
    res = {}
    for i = #t, 1, -1 do
        table.insert(res, t[i])
    end
    return res
end

function table.length(t) -- 🤓
    local counter = 0
    for _ in pairs(t) do
        counter = counter + 1
    end
    return counter
end

function table.chooseRandomElement(t)
    local rand = math.random(table.length(t))
    local ind = 1
    local choosen = nil 
    for _, elem in pairs(t) do
        if ind == rand then
            choosen = elem
        end
        ind = ind + 1
    end
    return choosen
end

-- END Table.lua
-- BEGIN Time.lua
Time = {
    t = 0,
    delta = 0,
}

function Time.update()
    local time = time()
    Time.delta = time - Time.t
    Time.t = time
end

function Time.dt()
    return Time.delta / 1000
end

function Time.dt_in_60fps()
    -- 60 / 1000 == 0.06
    return Time.dt() * 0.06
end

-- вместо Basic.tick_timer
function Time.tick(timer)
    return math.max(timer - Time.dt(), 0.0)
end
-- END Time.lua

-- BEGIN Anime.lua

Anime = {}

--[[
animation представляется собой таблицу кадров
Каждый кадр состоит из необходимых параметров:
id и T (время кадра) и t (текущее время)
]]

function Anime.tick(animation)
    local a = animation[animation.i]
    if a.t == 0 or a.t == nil then
        a.t = a.T
    end

    if a.t < 0 then  -- статический кадр
        return
    end

    a.t = Time.tick(a.t)
    if a.t == 0 then
        -- TODO: погуглить: безопасно ли брать размер таблицы, в которой есть как именные поля, так и поля по числу?
        -- if animation.is_loop then
        animation.i = animation.i % #animation + 1
        -- else
            -- animation.i = math.min(animation.i + 1, #animation)
        -- end
    end
end

-- END Anime.lua
-- BEGIN TextWithOutline.lua
TextWithOutline = {}

function TextWithOutline.print(text, x, y, outline_width, color_text, color_outline, size, is_square)
    -- is_square значит, что обводка квадратная, а не круглая
    size = size or 1
    for dx = -outline_width, outline_width do
        for dy = -outline_width, outline_width do
            if is_square or dx^2 + dy^2 <= outline_width^2 then
                print(text, x+dx, y+dy, color_outline, false, size)
            end
        end
    end
    print(text, x, y, color_text, false, size)
end


-- function TextWithOutline.get_default_animation(text, x, y, outline_width, color_text, color_outline, size, is_square)

-- end

-- function TextWithOutline.update_dafault_animation(animation)
--     if animation.t == 0 then
--         animation.t = animation.T
--         if animation.is_reverse then
--             animation.outline_width = math.max(0, animation.outline_width - 1)
--         end
--     else
--         animation.t = Basic.tick_timer(animation.t)
--     end
-- end
-- END TextWithOutline.lua
-- BEGIN Collision.lua
Collision = {}

-- function Collision.is_collide_with_smth()
--     for _, e in 
-- end

function Collision.lineIntersectsRect(x1, y1, x2, y2, rx1, ry1, rx2, ry2)
    -- нормализуем прямоугольник
    if rx1 > rx2 then rx1, rx2 = rx2, rx1 end
    if ry1 > ry2 then ry1, ry2 = ry2, ry1 end

    local dx = x2 - x1
    local dy = y2 - y1

    local t0 = 0
    local t1 = 1

    local function clip(p, q)
        if p == 0 then
            return q >= 0
        end

        local r = q / p

        if p < 0 then
            if r > t1 then return false end
            if r > t0 then t0 = r end
        else
            if r < t0 then return false end
            if r < t1 then t1 = r end
        end

        return true
    end

    return clip(-dx, x1 - rx1)
       and clip( dx, rx2 - x1)
       and clip(-dy, y1 - ry1)
       and clip( dy, ry2 - y1)
end

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
-- END Collision.lua
-- BEGIN Settings.lua
Settings = {
    volume = 15,
    bpm = 800,
}
-- END Settings.lua
-- BEGIN ChangeScreenAnimator.lua

ChangeScreenAnimator = {}

function ChangeScreenAnimator:new()
    local object = {
        T = 0.01,  -- time per frame
        DELAY = 0.25, -- s
        x = 0, -- current x-coord
        speed = 10,
        x_limit = 210,
        y = 119, -- const
        is_reverse = false,
    }
    object.t = object.T

    setmetatable(object, self)
    return object
end

function ChangeScreenAnimator:update()
    self.t = Time.tick(self.t)
    if self.t == 0 then
        self.t = self.T
        if self.is_reverse then
            self.x = math.max(0, self.x - self.speed)
        else
            if self.x == self.x_limit then
                self.is_reverse = true
                self.t = self.DELAY
            end
            self.x = math.min(self.x_limit, self.x + self.speed)
        end
    end
end

function ChangeScreenAnimator:is_end()
    return self.x == 0 and self.is_reverse
end

function ChangeScreenAnimator:is_middle()
    return self.x == self.x_limit
end

function ChangeScreenAnimator:draw()
    -- if self.is_reverse then
    --     map(self.screen_after.x, self.screen_after.y)
    -- else
    --     map(self.screen_before.x, self.screen_before.y)
    -- end
    map(self.x, self.y, 30,17,0,0, 7)
end

ChangeScreenAnimator.__index = ChangeScreenAnimator
-- END ChangeScreenAnimator.lua
-- BEGIN RestartDialog.lua
RestartDialog = {}

function RestartDialog:new()
    local object = {
        is_accepted = false,
    }
    setmetatable(object, self)
    return object
end

function RestartDialog:update()
    if key.ok() then
        self.is_accepted = true
    end
end

function RestartDialog:draw()
    local x = 7
    local y = 7
    local outline_width = 4
    local color_text = 4
    local color_outline = 2
    local size = 2
    -- TextWithOutline.print("You looks like dead beef", x, y, outline_width, color_text, color_outline, size)
    TextWithOutline.print("RESTART?", x, y, outline_width, color_text, color_outline, size)
    local shadow_color = 7
    local button_color = 3
    y = SCREEN_HEIGHT - outline_width*2 - 10
    TextWithOutline.print("Z", x, y+1, outline_width, shadow_color, shadow_color, size, true)
    TextWithOutline.print("Z", x, y, outline_width, color_text, button_color, size, true)
end


RestartDialog.__index = RestartDialog
-- END RestartDialog.lua
-- BEGIN Preview.lua
-- это стартовый экран, но мне уже лень переименовывать

Preview = {}

function Preview:new()
    local object = {
        is_accepted = false,
    }
    setmetatable(object, self)
    return object
end

function Preview:update()
    if key.ok() then
        self.is_accepted = true
    end
end

function Preview:draw()
    local x = 4
    local y = 4
    local dy = 8
    local outline_width = 1
    local color = 4
    -- local color_outline = C0
    local size = 1
    local shadow_color = 6

    for _, line in ipairs(Preview.TEXT) do
        print(line, x, y+1, shadow_color)
        print(line, x, y, color)
        y = y + dy
    end
    -- TextWithOutline.print("You looks like dead beef", x, y, outline_width, color_text, color_outline, size)
    -- TextWithOutline.print("RESTART?", x, y, outline_width, color_text, color_outline, size, true)
    -- local button_color = 3
    -- y = SCREEN_HEIGHT - outline_width*2 - 10
    -- TextWithOutline.print("Z", x, y+1, outline_width, shadow_color, shadow_color, size, true)
    -- TextWithOutline.print("Z", x, y, outline_width, color_text, button_color, size, true)
end


Preview.__index = Preview
-- END Preview.lua
-- BEGIN WinScreen.lua
WinScreen = {}

function WinScreen:new()
    local object = {
        is_accepted = false,
    }
    setmetatable(object, self)
    return object
end

function WinScreen:update()
    if key.ok() then
        self.is_accepted = true
    end
end

function WinScreen:draw()
    local x = 4
    local y = 4
    local dy = 8
    local outline_width = 1
    local color = 4
    -- local color_outline = C0
    local size = 1
    local shadow_color = 6

    for _, line in ipairs(WinScreen.TEXT) do
        print(line, x, y+1, shadow_color)
        print(line, x, y, color)
        y = y + dy
    end
    -- TextWithOutline.print("Z", x, y+1, outline_width, shadow_color, shadow_color, size, true)
    -- TextWithOutline.print("Z", x, y, outline_width, color_text, button_color, size, true)
end


WinScreen.__index = WinScreen
-- END WinScreen.lua

-- Невероятно душные модули. Я их ненавижу
-- BEGIN Sheet.lua
-- вспомогательный класс для нот
Note = {
    pivot = 36, -- 🍺 см. load
}
function Note:new(pitch, sound, channel, volume, speed)
    if pitch == nil then
        -- это нота-заглушка
        pitch = -Note.pivot
        sound = -1 -- значит звука нет
    end
    if speed == nil then
        speed = 0
    end
    object = {
        pitch = Note.pivot + pitch, -- [0, 95] 🍺
        sound = sound,
        channel = channel, -- [0, 3]
        volume = volume or 0.5, -- [0, 1]f
        speed = speed
    }
    if object.pitch < 0 or object.pitch > 95 then
        trace('плохой пивот')
        return '🍺'
    end
    setmetatable(object, self)
    return object
end

function Note:play()
    if self.sound == -1 then
        return
    end    

    local duration = 46
    sfx(self.sound, self.pitch, duration, self.channel, self.volume*Settings.volume, self.speed)
end

Note.__index = Note




Sheet = {}

function Sheet.make_tact(note, pos)
    -- генерирует такт с одной нотой
    local tact = {}
    for i = 1, BEATS_IN_TACT do
        if i == pos then
            tact[i] = note
        else
            tact[i] = false
        end
    end
    return tact
end

function Sheet.concat(tacts)
    local res = {}
    for _, t in ipairs(tacts) do
        for i = 1, BEATS_IN_TACT do
            table.insert(res, t[i])
        end
    end
    return res
end

function Sheet.load() -- вызывается в Data   
    Sheet.is_boss = false 
    Sheet.drum1 = {}
    Sheet.drum1.normal = Sheet.concat({
        Sheet.make_tact(Note:new(7, 12,0), 1),
        Sheet.make_tact(Note:new(7, 12,0), 1),
        Sheet.make_tact(Note:new(7, 12,0), 1),
        Sheet.make_tact(Note:new(7, 12,0), 1),

        Sheet.make_tact(Note:new(3, 12,0), 1),
        Sheet.make_tact(Note:new(3, 12,0), 1),
        Sheet.make_tact(Note:new(3, 12,0), 1),
        Sheet.make_tact(Note:new(3, 12,0), 1),
    })

    Sheet.drum2 = {}
    Sheet.drum2.normal = Sheet.concat({
        Sheet.make_tact(Note:new(14, 12,0), 3),
        Sheet.make_tact(Note:new(14, 12,0), 3),
        Sheet.make_tact(Note:new(14, 12,0), 3),
        Sheet.make_tact(Note:new(14, 12,0), 3),

        Sheet.make_tact(Note:new(10, 12,0), 3),
        Sheet.make_tact(Note:new(10, 12,0), 3),
        Sheet.make_tact(Note:new(10, 12,0), 3),
        Sheet.make_tact(Note:new(10, 12,0), 3),
    })

    Sheet.drum3 = {}
    Sheet.drum3.normal = Sheet.concat({
        Sheet.make_tact(Note:new(19, 12,0), 9),
        Sheet.make_tact(Note:new(19, 12,0), 9),
        Sheet.make_tact(Note:new(19, 12,0), 9),
        Sheet.make_tact(Note:new(19, 12,0), 9),

        Sheet.make_tact(Note:new(15, 12,0), 9),
        Sheet.make_tact(Note:new(15, 12,0), 9),
        Sheet.make_tact(Note:new(15, 12,0), 9),
        Sheet.make_tact(Note:new(15, 12,0), 9),
    })

    Sheet.drum4 = {}
    Sheet.drum4.normal = Sheet.concat({
        Sheet.make_tact(Note:new(22, 12,0), 11),
        Sheet.make_tact(Note:new(22, 12,0), 11),
        Sheet.make_tact(Note:new(22, 12,0), 11),
        Sheet.make_tact(Note:new(22, 12,0), 11),

        Sheet.make_tact(Note:new(19, 12,0), 11),
        Sheet.make_tact(Note:new(19, 12,0), 11),
        Sheet.make_tact(Note:new(19, 12,0), 11),
        Sheet.make_tact(Note:new(19, 12,0), 11),
    })

    Sheet.bell1 = {}
    Sheet.bell1.normal = Sheet.concat({
        Sheet.make_tact(Note:new(10, 8,1), 1),
        Sheet.make_tact(Note:new(10, 8,1), 1),
        Sheet.make_tact(Note:new(10, 8,1), 1),
        Sheet.make_tact(Note:new(10, 8,1), 1),

        Sheet.make_tact(Note:new(10, 8,1), 1),
        Sheet.make_tact(Note:new(10, 8,1), 1),
        Sheet.make_tact(Note:new(10, 8,1), 1),
        Sheet.make_tact(Note:new(10, 8,1), 1),

        Sheet.make_tact(Note:new(9, 8,1), 1),
        Sheet.make_tact(Note:new(9, 8,1), 1),
        Sheet.make_tact(Note:new(9, 8,1), 1),
        Sheet.make_tact(Note:new(9, 8,1), 1),

    })

    Sheet.bell2 = {}
    Sheet.bell2.normal = Sheet.concat({
        Sheet.make_tact(Note:new(22, 8,2), 5),
        Sheet.make_tact(Note:new(22, 8,2), 5),
        Sheet.make_tact(Note:new(22, 8,2), 5),
        Sheet.make_tact(Note:new(22, 8,2), 5),

        Sheet.make_tact(Note:new(19, 8,2), 5),
        Sheet.make_tact(Note:new(19, 8,2), 5),
        Sheet.make_tact(Note:new(19, 8,2), 5),
        Sheet.make_tact(Note:new(19, 8,2), 5),

        Sheet.make_tact(Note:new(17, 8,2), 5),
        Sheet.make_tact(Note:new(17, 8,2), 5),
        Sheet.make_tact(Note:new(17, 8,2), 5),
        Sheet.make_tact(Note:new(17, 8,2), 5),

    })

    Sheet.bell3 = {}
    Sheet.bell3.normal = Sheet.concat({
        Sheet.make_tact(Note:new(14, 8,1), 9),
        Sheet.make_tact(Note:new(14, 8,1), 9),
        Sheet.make_tact(Note:new(14, 8,1), 9),
        Sheet.make_tact(Note:new(14, 8,1), 9),

        Sheet.make_tact(Note:new(14, 8,1), 9),
        Sheet.make_tact(Note:new(14, 8,1), 9),
        Sheet.make_tact(Note:new(14, 8,1), 9),
        Sheet.make_tact(Note:new(14, 8,1), 9),

        Sheet.make_tact(Note:new(12, 8,1), 9),
        Sheet.make_tact(Note:new(12, 8,1), 9),
        Sheet.make_tact(Note:new(12, 8,1), 9),
        Sheet.make_tact(Note:new(12, 8,1), 9),

    })

    Sheet.bell4 = {}
    Sheet.bell4.normal = Sheet.concat({
        Sheet.make_tact(Note:new(22, 8,2), 13),
        Sheet.make_tact(Note:new(22, 8,2), 13),
        Sheet.make_tact(Note:new(22, 8,2), 13),
        Sheet.make_tact(Note:new(22, 8,2), 13),

        Sheet.make_tact(Note:new(19, 8,2), 13),
        Sheet.make_tact(Note:new(19, 8,2), 13),
        Sheet.make_tact(Note:new(19, 8,2), 13),
        Sheet.make_tact(Note:new(19, 8,2), 13),

        Sheet.make_tact(Note:new(17, 8,2), 13),
        Sheet.make_tact(Note:new(17, 8,2), 13),
        Sheet.make_tact(Note:new(17, 8,2), 13),
        Sheet.make_tact(Note:new(17, 8,2), 13),

    })
end

function Sheet.load_boss()
    -- Note.pivot = 36+12 -- 🍺
    local H = 0
    local X = 3
    Sheet.is_boss = true


    Sheet.drum1 = {}
    Sheet.drum1.normal = Sheet.concat({
        Sheet.make_tact(false, 1),
        Sheet.make_tact(false, 1),

        -- Sheet.make_tact(Note:new(7, 12,0), 1),
    })

    Sheet.drum2 = {}
    Sheet.drum2.normal = Sheet.concat({
        Sheet.make_tact(false, 1),
        Sheet.make_tact(false, 1),

        -- Sheet.make_tact(Note:new(14, 12,0), 3),
    })

    Sheet.drum3 = {}
    Sheet.drum3.normal = Sheet.concat({
        Sheet.make_tact(false, 1),
        Sheet.make_tact(false, 1),

        -- Sheet.make_tact(Note:new(19, 12,0), 9),
    })

    Sheet.drum4 = {}
    Sheet.drum4.normal = Sheet.concat({
        Sheet.make_tact(false, 1),
        Sheet.make_tact(false, 1),

        -- Sheet.make_tact(Note:new(22, 12,0), 11),
    })

    Sheet.bell1 = {}
    Sheet.bell1.normal = Sheet.concat({
        Sheet.make_tact(false, 1),
        Sheet.make_tact(Note:new(2+H, 8,1), 1),
        Sheet.make_tact(Note:new(2+H, 8,1), 1),
        Sheet.make_tact(Note:new(0+H, 8,1), 1),
        Sheet.make_tact(Note:new(0+H, 8,1), 1),
        Sheet.make_tact(false, 1),
    })

    Sheet.bell2 = {}
    Sheet.bell2.normal = Sheet.concat({
        Sheet.make_tact(false, 1),
        Sheet.make_tact(Note:new(5+H, 8,2), 2),
        Sheet.make_tact(Note:new(5+H, 8,2), 2),
        Sheet.make_tact(Note:new(5+H, 8,2), 2),
        Sheet.make_tact(Note:new(5+H, 8,2), 2),
        Sheet.make_tact(false, 1),
    })

    Sheet.bell3 = {}
    Sheet.bell3.normal = Sheet.concat({
        Sheet.make_tact(false, 1),
        Sheet.make_tact(Note:new(10+H, 8,1), 3),
        Sheet.make_tact(Note:new(10+H, 8,1), 3),
        Sheet.make_tact(Note:new(12+H, 8,1), 3),
        Sheet.make_tact(Note:new(12+H, 8,1), 3),
        Sheet.make_tact(false, 1),

    })

    Sheet.bell4 = {}
    Sheet.bell4.normal = Sheet.concat({
        Sheet.make_tact(false, 1),
        Sheet.make_tact(Note:new(14+H, 8,2), 4),
        Sheet.make_tact(Note:new(14+H, 8,2), 4),
        Sheet.make_tact(Note:new(17+H, 8,2), 4),
        Sheet.make_tact(Note:new(17+H, 8,2), 4),
        Sheet.make_tact(false, 1),
    })
end

-- END Sheet.lua
-- BEGIN Generation.lua

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
-- END Generation.lua
--

-- BEGIN Player.lua
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

    if self.i_time > 0 then
        if math.random() < Player.HURT_REACTION then
            return
        end
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
    if object.cost == 0 or game.money == 0 then
        return
    end
    if self.payment_t == 0 then
        self.payment_T = self.payment_T * Player.PAYMENT_ACC
        self.payment_t = self.payment_T
        object.cost = object.cost - 1
        game.money = game.money - 1
        Player.PAY_NOTE:play()
    end

end

Player.__index = Player
-- END Player.lua

-- здесь смешным комментов нет. мне было не до шуток

Enemy = {}
function Enemy:move(x, y)
    self.x = x
    self.y = y
end
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

function Enemy:earn_money()
    game.money = game.money + 1
    self.money_time = Enemy.MONEY_TIME -- для анимации
end


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

        money_time = 0,
        fear_time = 0, -- время страха призыва
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
        print(self.cost, self.x - 1, self.y + 10, Enemy.COST_COLOR, false,1, false)
        -- Collision.draw_box(Collision.get_interbox_by_object(self))
    end

    spr(self.sprite[self.sprite.i].id, self.x, self.y, C0,1)
    if self.money_time > 0 then
        print("+1", self.x, self.y - 5, Enemy.MONEY_COLOR)
    end
end

function PistonEnemy:update()
    if not self.is_active then
        self:activate_if_can()
    else
        Anime.tick(self.sprite)
        self.money_time = Time.tick(self.money_time)
        self.fear_time = Time.tick(self.fear_time)
    end
end

function PistonEnemy:activate_if_can()
    if self.cost == 0 and not self.is_active then
        self.is_active = true
        self.sprite = PistonEnemy.sprite.release
        self.fear_time = Enemy.FEAR_TIME
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

        money_time = 0,
        fear_time = 0,
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

function CircleEnemy:move(x, y)
    self.x = x
    self.y = y
    self.chambered_bullet = Bullet:new(x-1, y-1)
end


function CircleEnemy:draw()
    if not self.is_active then
        -- Collision.draw_box(Collision.get_interbox_by_object(self))
        TextWithOutline.print(self.cost, self.x - 5, self.y + 8, 2, Enemy.COST_COLOR,C0, 1, true)

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

    if self.money_time > 0 then
        print("+1", self.x - 3, self.y - CircleEnemy.R - 7, Enemy.MONEY_COLOR)
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

    self.money_time = Time.tick(self.money_time)
    self.fear_time = Time.tick(self.fear_time)
end

function CircleEnemy:activate_if_can()
    if self.cost == 0 and not self.is_active then
        self.is_active = true
        self.fear_time = Enemy.FEAR_TIME
    end
end

CircleEnemy.__index = CircleEnemy



Director = {}

function Director.init()
    -- будет работать по метроному
    -- но сейчас все максимально просто, потом я это все снесу
    -- upd: уже не актуально. Я уже все снес
    Director.T = 60 / Settings.bpm
    Director.t = Director.T

    Director.beat_counter = 0
end

function Director:update()
    Director.t = Time.tick(Director.t)
    if Director.t == 0 then
        Director.t = 60 / Settings.bpm

        -- if Sheet.is_boss and Director.beat_counter >= 16*9 then
        --     Sheet.load()
        -- end

        -- спавн бонусов
        -- if #game.bonuses == 0 then
        --     local x = math.random(5, 28) * 8
        --     local y = math.random(4, 15) * 8
        --     while 

        --     table.insert(game.bonuses, Bonus:new())
        -- end
        --

        -- мама, я хочу свою event-систему
        -- нет, у нас есть event-система дома
        -- event-система дома:
        for part, e in pairs(game.enemies) do
            if not e.is_active or e.fear_time > 0 then
                goto continue
            end
            local current_i = (Director.beat_counter - 1) % #Sheet[part].normal + 1
            local prev_i = (Director.beat_counter - 2) % #Sheet[part].normal + 1
            local next_i = (Director.beat_counter) % #Sheet[part].normal + 1
            local current_note = Sheet[part].normal[current_i]
            local prev_note = Sheet[part].normal[prev_i]
            local next_note = Sheet[part].normal[next_i]
            if current_note then
                e:attack()
                current_note:play()
                e:earn_money()
            elseif prev_note then
                e:release()
            end
            if next_note then
                e:prepare()
            end
            ::continue::
        end
        Director.beat_counter = Director.beat_counter + 1
    end
end

-- BEGIN key.lua

tic80_key = key
key = {}

function key.down()
    return btn(1) or tic80_key(KEY_S)
end

function key.up()
    return btn(0) or tic80_key(KEY_W)
end

function key.left()
    return btn(2) or tic80_key(KEY_A)
end

function key.right()
    return btn(3) or tic80_key(KEY_D)
end

function key.action()
    -- ЛУЧШИЙ БАН ПЕРЕКАТА
    -- return btnp(4)
    return false
end

function key.ok()
    return btnp(4)
end
-- END key.lua
-- BEGIN Bullet.lua

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
-- END Bullet.lua
-- BEGIN Game.lua

game = {}

function shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end


function game.init()
    game.status='preview'
    game.preview = Preview:new()
    game.restart()
end

function game.restart()
    game.flag = false

    Note.pivot = 36
    game.bpm_t = 0
    game.bpm_d = 1
    game.bpm_T = 0.1


    Settings.bpm = 840
    game.is_final = false
    game.survive_time_left = game.SURVIVE_TIME
    -- game.is_win = false

    game.player = Player:new(14*8, 7*8)
    game.restart_dialog = false
    game.death_time = 0 -- задержка экрана во время смерти

    Director.init()
    local temp = 20 -- уже не актуально
    game.enemies = {
        drum1 = PistonEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
        drum2 = PistonEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
        drum3 = PistonEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
        drum4 = PistonEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
        -- disco = Discoball:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
        bell1 = CircleEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
        bell2 = CircleEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
        bell3 = CircleEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
        bell4 = CircleEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
    }  -- список всех противников по ролям
    game.bullets = {}
    -- game.bonuses = {}
    game.money = 0

    local t = {
        -- 'disco',
        'drum1',
        'drum2',
        'drum3',
        'drum4',
        'bell1',
        'bell2',
        'bell3',
        'bell4',
    }

    -- расстановка
    local places = Generation.get_places(#t)
    Generation.sort_by_center(places)
    local i = 1
    for _, place in ipairs(places) do
        local e = game.enemies[t[i]]
        local x = place.x*8 + 10
        local y = place.y*8 + 14
        e:move(x, y)
        i = i + 1
    end
    --

    -- установка стоимостей
    shuffle(t)
    local cost = {
        -- 0, 0, 0, 0, 0, 0, 0, 0,
        0, 5, 10, 25, 25, 50, 50, 100
    }

    -- local delta_cost = 5
    -- local delta_delta_cost = 5
    for _, key in ipairs(t) do
        game.enemies[key].cost = cost[_]
        -- cost = cost + delta_cost
        -- delta_cost = delta_cost + delta_delta_cost
    end

    Sheet.load()
    Director.beat_counter = 0
end

function game.update()
    if game.status == 'action' then
        if not game.is_final and game.is_all_active() then
            game.is_final = true
            Settings.bpm = 750
        end
        -- if game.survive_time_left < 12 and not game.flag then
        --     Director.beat_counter = 0
        --     Note.pivot = Note.pivot+12
        --     Sheet.load_boss()
        --     game.flag = true
        -- end

        -- if game.is_final then
            -- if game.bpm_t == 0 then
            --     game.bpm_t = game.bpm_T
            --     -- Settings.bpm = math.min(1300, Settings.bpm + 10)
            -- end
            -- game.bpm_t = Time.tick(game.bpm_t)
            -- trace(Settings.bpm)
        -- end

        game.player:update()
        Director:update()
        local player_rect = Collision.get_hitbox_by_object(game.player)

        local is_player_pay = false
        for _, e in pairs(game.enemies) do
            e:update()
            local eb = Collision.get_interbox_by_object(e)
            if Collision.check(player_rect, eb) then
                game.player:pay(e)
                is_player_pay = true
            end
        end
        if not is_player_pay then
            game.player.payment_T = Player.PAYMENT_FREQ
        end

        local should_be_deleted = {}
        local _d = 5
        for i, b in ipairs(game.bullets) do
            b:update()
            local b_rect = Collision.get_hitbox_by_object(b)
            if Collision.check(player_rect, b_rect) then
                game.player:hurt()
            end
            if b.x > SCREEN_WIDTH + _d or b.x < -_d or b.y > SCREEN_HEIGHT + _d or b.y < -_d then
                table.insert(should_be_deleted, i)
            end
        end

        for j = #should_be_deleted, 1, -1 do
            local i = should_be_deleted[j]
            table.remove(game.bullets, i)
        end

        if game.player.hp <= 0 then
            game.status = 'death'
        end

        if game.is_final then
            if game.survive_time_left == 0 then
                -- game.is_win = true
                game.status = 'win'
                game.win_screen = WinScreen:new()
                game.screen_animator = ChangeScreenAnimator:new()                
                -- game.restart()
            end
            game.survive_time_left = Time.tick(game.survive_time_left)
        end

    elseif game.status == 'death' then
        game.screen_animator = ChangeScreenAnimator:new()
        game.status = 'restart_menu'
        game.death_time = game.DEATH_TIME
        game.restart_dialog = RestartDialog:new()
    elseif game.status == 'win' then
        game.win_screen:update()
        if game.win_screen.is_accepted then
            game.screen_animator:update()
            if game.screen_animator:is_middle() then
                game:restart()
                game.sholud_draw_all = true
                -- game.should_draw_preview = true
            end
            if game.screen_animator:is_end() then
                -- game:init()
                game.status = 'action'
                game.sholud_draw_all = false
                -- game.should_draw_preview = false
            end
        end
    elseif game.status == 'restart_menu' then
        if game.death_time == 0 then
            if game.restart_dialog then
                game.restart_dialog:update()
            end
            if game.restart_dialog == false or game.restart_dialog.is_accepted then
                game.screen_animator:update()
                if game.screen_animator:is_middle() then
                    game:restart()
                end
                if game.screen_animator:is_end() then
                    game.status = 'action'
                end
            end
        else
            game.death_time = Time.tick(game.death_time)
        end
    elseif game.status == 'preview' then
        if key.ok() then
            game.restart()
            game.status = 'action'
        end
    end
end

function game.is_all_active()
    for _, e in pairs(game.enemies) do
        if not e.is_active then
            return false
        end
    end
    return true
end

function game.draw_all()
    rectb(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 6)

    for _, e in pairs(game.enemies) do
        e:draw()
    end
    for _, b in ipairs(game.bullets) do
        b:draw()
    end

    if game.is_final then
        print('SURVIVE', 3, 11, GOLD)
        -- +0.12 для драматизма
        print("0:"..tostring(math.floor(game.survive_time_left+0.12)), 3, 11 + 10, DARK_GOLD)
    else
        print(game.money, 3, 11, GOLD)
    end

    if not(game.status == 'restart_menu' and game.death_time == 0) then
        game.player:draw()
    end

    if game.restart_dialog and game.death_time == 0 then
        game.restart_dialog:draw()
    end

    if game.should_draw_preview then
        cls(C0)
        game.preview:draw()
    end

    if game.screen_animator then
        game.screen_animator:draw()
    end
end

function game.draw()
    -- if game.status == 'action' then
    if game.status == 'preview' then
        game.preview:draw()
    elseif game.status == 'win' then
        game.win_screen:draw()
        if game.sholud_draw_all then
            game.draw_all()
        end
        if game.screen_animator then
            game.screen_animator:draw()
        end
    else
        game.draw_all()
    end
end
-- END Game.lua

-- Устанавливает все константы, привязанные к классам
-- Поэтому реквайрится в конце 🤌
-- BEGIN Data.lua

-- Bonus.T = Settings.bpm * 4 / 60.
-- Bonus.TIME_TO_LIVE = 6.7

Preview.TEXT = {
    'Music was once produced in MUSIC FACTORIES', 'like this one.', '',
    'Then synthesizers became popular,', 'and MUSIC FACTORIES were no longer needed', ':-(','',
    'You bought a MUSIC FACTORY.','',
    'Bring the MUSIC FACTORY back to life', 'and produce music again!',
    '','','','',
    '                <press Z to continue>',
}
WinScreen.TEXT = {
    'You restored the MUSIC FACTORY!', '',
    'Beautiful music fills the air  :-D', '',
    'Your neighbors are happy!', '', 'They thank you for bringing','the MUSIC FACTORY back.',
    '','','','',
    '','',
    '                <press Z to restart>',
}

KEY_W = 23
KEY_A = 01
KEY_S = 19
KEY_D = 04

BEATS_IN_TACT = 16 -- мы все умрем если это изменить

SCREEN_WIDTH = 240
SCREEN_HEIGHT = 136

-- цвета
GOLD = 14
DARK_GOLD = 15
--

game.DEATH_TIME = 0.5
game.SURVIVE_TIME = 30--42

Player.ROLL_TIME = 0.25

Player.SPEED = 54
Player.SPEED = 43.5
Player.ROLL_SPEED = Player.SPEED * 2.3
Player.ROLL_COOLDOWN = 0.21
Player.ROLL_BUFFER = 0.0

-- начальная частота оплаты
Player.PAYMENT_FREQ = 0.15
-- коэффициент ускорения оплаты
Player.PAYMENT_ACC = 0.9

Player.sprite = {
    stay = {
        i = 1,
        {id=257, T=-1},
    },
    run = {
        i = 1,
        {id=256, T=0.08},
        {id=257, T=0.08},
        {id=258, T=0.09},
        {id=259, T=0.08},
    },
    roll = {
        i = 1,
        {id=320, T=Player.ROLL_TIME / 7},
        {id=321, T=Player.ROLL_TIME / 7},
        {id=322, T=Player.ROLL_TIME / 7},
        {id=323, T=Player.ROLL_TIME / 7},
        {id=324, T=Player.ROLL_TIME / 7 * 2},
        {id=325, T=-1},
    },
}
Player.HITBOX = { -- обе границы включены
    x1 = 2, y1 = 2,
    x2 = 5, y2 = 6,
}
Player.HP = 6
Player.I_TIME = 0.6

Player.PAY_NOTE = Note:new(22+12, 0, 0, 0.34, 3)

Player.HURT_REACTION = 0.4 -- степень мерцания при получении урона

FULL_HEART_SPRITE = 260
HALF_HEART_SPRITE = 261
EMPTY_HEART_SPRITE = 262


PistonEnemy.sprite = {
    inactive = {
        i = 1,
        {id = 464, T = -1},
    },
    activating = {
        i = 1,
        {id = 469, T = 0.05},
        {id = 464, T = 0.05},
    },

    warning = {
        i = 1,
        -- {id = 496, T = -1},
        {id = 465, T = -1},
    },
    prepare = {
        i = 1,
        -- {id = 497, T = -1},
        {id = 466, T = 0.05},
        {id = 467, T = -1},
    },
    attack = {
        i = 1,
        -- {id = 498, T = 0.05},
        -- {id = 499, T = 0.025},
        -- {id = 500, T = 0.025},
        -- {id = 501, T = 0.06},
        -- {id = 502, T = -1},
        {id = 468, T = -1},
    },
    release = {
        i = 1,
        -- {id = 503, T = 0.05},
        -- {id = 504, T = 0.05},
        -- {id = 496, T = -1},
        {id = 469, T = -1},
    },
}
PistonEnemy.HITBOX = {x1=1, y1=1, x2=6, y2=7}
PistonEnemy.INTERBOX = {x1=-4, y1=-3, x2=13, y2=17} 
-- hitbox for INTERaction 🤪


CircleEnemy.R = 5
CircleEnemy.PULLBACK_DISTANCE = 2
CircleEnemy.HITBOX = {x=0, y=0, r=CircleEnemy.R, is_circle=true}
-- CircleEnemy.INTERBOX = {x=0, y=0, r=CircleEnemy.R+6, is_circle=true}
CircleEnemy.INTERBOX = {x1=-(CircleEnemy.R+4), y1=-(CircleEnemy.R+4), x2=CircleEnemy.R+4, y2=CircleEnemy.R+4}
-- CircleEnemy.PRERELEASE_TIME = 0.08 -- задержка появления

-- Discoball.R = 8
-- Discoball.COLOR = 4
-- Discoball.INTERBOX = {x=0, y=0, r=Discoball.R+5, is_circle=true}

-- Laser.ATTACK_TIME = 0.6

Enemy.default_cost = 10
Enemy.MONEY_TIME = 0.5
Enemy.MONEY_COLOR = DARK_GOLD
Enemy.COST_COLOR = 7
Enemy.FEAR_TIME = 0.76

Bullet.speed = 24

Sheet.load()
-- END Data.lua

game.init()
function TIC()
    cls(C0)
    Time.update()
    
    game.update()
    game.draw()
end