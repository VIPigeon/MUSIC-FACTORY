
ChangeScreenAnimator = {}

function ChangeScreenAnimator:new()
    local object = {
        T = 0.01,  -- time per frame
        DELAY = 0.25, -- s
        x = 0, -- current x-coord
        speed = 10,
        x_limit = 210,
        y = 119, -- const
        is_reverse = false,
    }
    object.t = object.T

    setmetatable(object, self)
    return object
end

function ChangeScreenAnimator:update()
    self.t = Time.tick(self.t)
    if self.t == 0 then
        self.t = self.T
        if self.is_reverse then
            self.x = math.max(0, self.x - self.speed)
        else
            if self.x == self.x_limit then
                self.is_reverse = true
                self.t = self.DELAY
            end
            self.x = math.min(self.x_limit, self.x + self.speed)
        end
    end
end

function ChangeScreenAnimator:is_end()
    return self.x == 0 and self.is_reverse
end

function ChangeScreenAnimator:is_middle()
    return self.x == self.x_limit
end

function ChangeScreenAnimator:draw()
    -- if self.is_reverse then
    --     map(self.screen_after.x, self.screen_after.y)
    -- else
    --     map(self.screen_before.x, self.screen_before.y)
    -- end
    map(self.x, self.y, 30,17,0,0, 7)
end

ChangeScreenAnimator.__index = ChangeScreenAnimator
