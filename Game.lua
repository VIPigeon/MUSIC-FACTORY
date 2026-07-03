
game = {status='action'}

function shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end


local temp = 20
function game.init()
    game.player = Player:new(14*8, 7*8)
    game.restart_dialog = false
    game.death_time = 0 -- задержка экрана во время смерти

    Director.init()
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
        0, 5, 10, 25, 25, 50, 50, 100
    }
    -- local delta_cost = 5
    -- local delta_delta_cost = 5
    for _, key in ipairs(t) do
        game.enemies[key].cost = cost[_]
        -- cost = cost + delta_cost
        -- delta_cost = delta_cost + delta_delta_cost
    end
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
            trace(i)
        end

        if game.player.hp <= 0 then
            game.status = 'death'
        end

    elseif game.status == 'death' then
        game.screen_animator = ChangeScreenAnimator:new()
        game.status = 'restart_menu'
        game.death_time = game.DEATH_TIME
        game.restart_dialog = RestartDialog:new()
    elseif game.status == 'restart_menu' then
        if game.death_time == 0 then
            if game.restart_dialog then
                game.restart_dialog:update()
            end
            if game.restart_dialog == false or game.restart_dialog.is_accepted then
                game.screen_animator:update()
                if game.screen_animator:is_middle() then
                    game:init()
                end
                if game.screen_animator:is_end() then
                    game.status = 'action'            
                end
            end
        else
            game.death_time = Time.tick(game.death_time)
        end
    end
end


function game.draw()
    -- if game.status == 'action' then
    if true then
        rectb(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 6)

        for _, e in pairs(game.enemies) do
            e:draw()
        end
        for _, b in ipairs(game.bullets) do
            b:draw()
        end

        print(game.money, 2, 11, GOLD)

        if not(game.status == 'restart_menu' and game.death_time == 0) then
            game.player:draw()
        end

        if game.restart_dialog and game.death_time == 0 then
            game.restart_dialog:draw()
        end
        if game.screen_animator then
            game.screen_animator:draw()
        end
    end
end

