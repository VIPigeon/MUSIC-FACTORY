
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
        Director.t = Director.T

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
