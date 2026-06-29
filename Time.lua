Time = {
    t = 0,
    delta = 0,
}

function Time.update()
    local time = time()
    Time.delta = time - Time.t
    Time.t = time
end

function Time.dt()
    return Time.delta / 1000
end

function Time.dt_in_60fps()
    -- 60 / 1000 == 0.06
    return Time.dt() * 0.06
end

-- вместо Basic.tick_timer
function Time.tick(timer)
    return math.max(timer - Time.dt(), 0.0)
end
