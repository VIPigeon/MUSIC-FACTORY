
game = {}

function game.init()
    game.status = 'action'
    game.player = Player:new(100, 100)
end

function game.action_update()
    game.player:update()
end

function game.update()
    if game.status == 'action' then
        game.action_update()
    end
end



function game.action_draw()
    game.player:draw()
end

function game.draw()
    if game.status == 'action' then
        game.action_draw()
    end
end

