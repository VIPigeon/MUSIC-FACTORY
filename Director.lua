
Director = {}

function Director.init()
    -- будет работать по метроному
    -- но сейчас все максимально просто, потом я это все снесу
    Director.T = 0.2
    Director.tick_counter = 0
    Director.t = Director.T
end

function Director:update()
    Director.t = Time.tick(Director.t)
    if Director.t == 0 then
        Director.t = Director.T

        -- мама, я хочу свою event-систему
        -- нет, у нас есть event-система дома
        -- event-система дома:
        local xk = Director.tick_counter % 5
        if xk == 1 then
            for _, e in ipairs(game.enemies) do
                e:prepare()
            end
        elseif xk == 2 then
            for _, e in ipairs(game.enemies) do
                e:attack()
            end
        elseif xk == 3 then
            for _, e in ipairs(game.enemies) do
                e:release()
            end
        elseif xk == 0 then
            for _, e in ipairs(game.enemies) do
                e:warning()
            end
        end

        Director.tick_counter = Director.tick_counter + 1
    end
end
