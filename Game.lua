
game = {}

function game.init()
    game.status = 'action'
    game.player = Player:new(100, 100)
    Director.init()
    game.enemies = {PistonEnemy:new(50, 50)}  -- список всех противников
    game.bullets = {}
end

function game.update()
    if game.status == 'action' then
        game.player:update()
        Director:update()
        for _, e in ipairs(game.enemies) do
            e:update()
        end

        local player_rect = Collision.get_rect_by_object(game.player)
        for _, b in ipairs(game.bullets) do
            b:update()
            local b_rect = Collision.get_rect_by_object(b)
            if Collision.check(player_rect, b_rect) then
                game.player:hurt()
            end
        end
    end
end


function game.draw()
    if game.status == 'action' then
        game.player:draw()
        for _, e in ipairs(game.enemies) do
            e:draw()
        end
        for _, b in ipairs(game.bullets) do
            b:draw()
        end
    end
end

