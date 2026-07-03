-- вспомогательный класс для нот
Note = {
    pivot = 36, -- 🍺
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

        -- Sheet.make_tact(Note:new(9, 8,1), 1),
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

        -- Sheet.make_tact(Note:new(17, 8,1), 5),
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

        -- Sheet.make_tact(Note:new(10, 8,1), 9),
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

        -- Sheet.make_tact(Note:new(17, 8,1), 13),
    })

    Sheet.disco = {}
    Sheet.disco.normal = Sheet.concat({
        Sheet.make_tact(Note:new(22, 8,3), 13),
        Sheet.make_tact(Note:new(22, 8,3), 13),
        Sheet.make_tact(Note:new(22, 8,3), 13),
        Sheet.make_tact(Note:new(22, 8,3), 13),

        Sheet.make_tact(Note:new(19, 8,3), 13),
        Sheet.make_tact(Note:new(19, 8,3), 13),
        Sheet.make_tact(Note:new(19, 8,3), 13),
        Sheet.make_tact(Note:new(19, 8,3), 13),

        -- Sheet.make_tact(Note:new(17, 8,1), 13),
    })
end
