
tic80_key = key
key = {}

function key.down()
    return btn(1) or tic80_key(KEY_S)
end

function key.up()
    return btn(0) or tic80_key(KEY_W)
end

function key.left()
    return btn(2) or tic80_key(KEY_A)
end

function key.right()
    return btn(3) or tic80_key(KEY_D)
end

function key.action()
    -- ЛУЧШИЙ БАН ПЕРЕКАТА
    -- return btnp(4)
    return false
end

function key.ok()
    return btnp(4)
end
