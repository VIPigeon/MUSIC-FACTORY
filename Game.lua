
game = {}

function game.init()
    game.status = 'action'
    game.player = Player:new(100, 100)
    Director.init()
    game.enemies = {PistonEnemy:new(50, 50), CircleEnemy:new(150, 50)}  -- список всех противников
    game.bullets = {}
    game.money = 9999
end

function game.update()
    if game.status == 'action' then
        game.player:update()
        Director:update()
        local player_rect = Collision.get_hitbox_by_object(game.player)

        local is_player_pay = false
        for _, e in ipairs(game.enemies) do
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

        for _, b in ipairs(game.bullets) do
            b:update()
            local b_rect = Collision.get_hitbox_by_object(b)
            if Collision.check(player_rect, b_rect) then
                game.player:hurt()
            end
        end
    end
end


function game.draw()
    if game.status == 'action' then
        for _, e in ipairs(game.enemies) do
            e:draw()
        end
        for _, b in ipairs(game.bullets) do
            b:draw()
        end

        print(game.money, 0, 9, 4)
        game.player:draw()
    end
end

