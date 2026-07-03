
game = {}

local temp = 20
function game.init()
    game.status = 'action'
    game.player = Player:new(100, 100)
    Director.init()
    game.enemies = {
        drum1 = PistonEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
        bell1 = CircleEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
        bell2 = CircleEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
        bell3 = CircleEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
        bell4 = CircleEnemy:new(math.random(temp, SCREEN_WIDTH - temp), math.random(temp, SCREEN_HEIGHT - temp)),
    }  -- список всех противников по ролям
    game.bullets = {}
    game.money = 9999
end

function game.update()
    if game.status == 'action' then
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
        rectb(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 6)

        for _, e in pairs(game.enemies) do
            e:draw()
        end
        for _, b in ipairs(game.bullets) do
            b:draw()
        end

        print(game.money, 2, 11, 4)
        game.player:draw()
    end
end

