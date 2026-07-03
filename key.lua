
key = {}

function key.down()
    return btn(1)
end

function key.up()
    return btn(0)
end

function key.left()
    return btn(2)
end

function key.right()
    return btn(3)
end

function key.action()
    -- ЛУЧШИЙ БАН ПЕРЕКАТА
    -- return btnp(4)
    return false
end

function key.ok()
    return btnp(4)
end
