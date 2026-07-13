
game = {}

function shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end


function game.init()
    -- pmem(1, 1)
    game.status='preview'
    game.preview = Preview:new()
    game.restart()
end

function game.restart()
    math.randomseed(time()*1e7)
    game.prev_money = 0
    game.time = 0

    game.flag = false

    Note.pivot = 36
    game.bpm_t = 0
    game.bpm_d = 1
    game.bpm_T = 0.1

    game.is_final = false
    game.survive_time_left = game.SURVIVE_TIME
    -- game.is_win = false

    game.coins = {Coin:new(3, 12, false)} -- для анимаций, только и всего
    game.player = Player:new(14*8, 7*8)
    -- game.player.hp = 1
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
    game.chests = {
        -- small = nil,
        big = nil,
    }
    -- game.bonuses = {}
    game.money = 0

    local t = {
        'drum1',
        'drum2',
        'drum3',
        'drum4',
        'big', -- большой сундук
        'small', -- маленький сундук
    }
    shuffle(t)
    table.concatTable(t,
        {
            'bell1',
            'bell2',
            'bell3',
            'bell4',
        }
    )

    -- расстановка
    local places = Generation.get_places(10)
    Generation.sort_by_center(places)
    local i = 1
    for _, place in ipairs(places) do
        if t[i] == 'small' or t[i] == 'big' then
            local chest = Chest:new(place.x*8 + 5, place.y*8 + 7, Chest.HP[t[i]])
            game.chests[t[i]] = chest
        else
            local e = game.enemies[t[i]]
            local x = place.x*8 + 10
            local y = place.y*8 + 14
            e:move(x, y)
        end
        i = i + 1
    end
    -- 

    -- установка стоимостей

    t = {
        'drum1',
        'drum2',
        'drum3',
        'drum4',
        'bell1',
        'bell2',
        'bell3',
        'bell4',
    }

    shuffle(t)
    local cost = {
        -- 0, 0, 0, 0, 0, 0, 0, 0,
        -- 0, 5, 10, 25, 25, 50, 50, 100,
        0, 10, 30, 30, 60, 60, 60, 120,
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

        for _, coin in ipairs(game.coins) do
            if game.is_player_pay then
                coin:update()
            else
                coin.animation.i = 1
            end
        end

        for _, c in pairs(game.chests) do
            if c.is_dead and c.reward == 0 then
                game.chests[_] = nil
            end
            c:update()
        end

        game.time = game.time + Time.dt()
        if not game.is_final and game.is_all_active() then
            game.is_final = true
            -- Settings.bpm = 750
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

        game.is_player_pay = false
        for _, e in pairs(game.enemies) do
            e:update()
            local eb = Collision.get_interbox_by_object(e)
            if Collision.check(player_rect, eb) then
                if game.money > 0 and not e.is_active then
                    game.is_player_pay = true
                end
                game.player:pay(e)
            end
        end
        if not game.is_player_pay then
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
            for _, c in pairs(game.chests) do
                if c.is_dead then
                    goto continue
                end
                local c_rect = Collision.get_hitbox_by_object(c)
                if Collision.check(c_rect, b_rect) then
                    c:get_damage()
                    table.insert(should_be_deleted, i)
                end
                ::continue::
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
                pmem(1, 1) -- запоминаем, что игрок победил
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
            set_normal_constants()
            game.restart()
            game.status = 'action'
        elseif key.speed_up_mode() and pmem(1)==1 then
            set_speed_up_constants()
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

    if game.is_final then
        print('SURVIVE', 3, 11, GOLD)
        -- +0.12 для драматизма
        print("0:"..tostring(math.floor(game.survive_time_left+0.12)), 3, 11 + 10, DARK_GOLD)
    else
        local c = GOLD
        -- if game.prev_money < game.money then
            -- c = GOLD-1 -- light gold
        if game.prev_money > game.money then
            c = DARK_GOLD
        end
        print(game.money, 3+7, 11, c)
        for _, coin in ipairs(game.coins) do
            coin:draw()
        end
    end
    if game.status == 'action' then
        print(math.floor(game.time / 60)..":"..math.floor(game.time % 60), 2, SCREEN_HEIGHT - 7, 6)
    end

    for _, c in pairs(game.chests) do
        c:draw()
    end
    for _, b in ipairs(game.bullets) do
        b:draw()
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

    game.prev_money = game.money
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
        qr.draw()
    else
        game.draw_all()
    end
end
