
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
    a.t = Time.tick(a.t)
    if a.t == 0 then
        -- TODO: погуглить: безопасно ли брать размер таблицы, в которой есть как именные поля, так и поля по числу?
        if animation.is_loop then
            animation.i = animation.i % #animation + 1
        else
            animation.i = math.min(animation.i + 1, #animation)
        end
    end
end

