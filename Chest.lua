Chest = {}

function Chest:new(x, y, hp)
    local object = {
        hp = hp,
        x = x,
        y = y,
        -- награда равна изначальному количеству hp
        reward = hp,
        init_reward = hp,
        sprite = Chest.sprite.static,
        die_t = Chest.DIE_T,
        is_dieing = false,
        hitbox = Chest.HITBOX,
        reward_t = 0,
        reward_T = Chest.REWARD_FREQ,
    }
    setmetatable(object, self)
    return object
end

function Chest:get_damage(damage)
    -- всегда один урон
    damage = damage or 1
    self.hp = math.max(0, self.hp - damage)
end

function Chest:draw()
    if self.is_dead then
        print('+'..self.init_reward, self.x, self.y+6, GOLD)
        return
    end
    spr(self.sprite[self.sprite.i].id, self.x, self.y, C0,1, 0,0, 2,2)
    local c = 4
    local sc = 7
    print(self.hp, self.x + 3, self.y + 10, sc)
    print(self.hp, self.x + 3, self.y + 9, c)
end

function Chest:earn_money()
    game.money = game.money + 1
    self.reward = self.reward - 1
end

function Chest:update()
    if self.is_dead and self.reward > 0 then
        if self.reward_t == 0 then
            self.reward_T = self.reward_T * Chest.REWARD_ACC
            self.reward_t = self.reward_T
            self:earn_money()
        end
        self.reward_t = Time.tick(self.reward_t)
        return
    end

    Anime.tick(self.sprite)
    local prev_status = self.is_dieing
    self.is_dieing = (self.hp == 0)
    if not prev_status and self.is_dieing then
        self.sprite = table.copy(Chest.sprite.dieing)
    end
    if self.is_dieing then
        if self.die_t == 0 then
            -- короче говоря
            -- сундук умер
            self.is_dead = true
            self.reward_t = self.reward_T
        end

        self.die_t = Time.tick(self.die_t)
    end
end

Chest.__index = Chest