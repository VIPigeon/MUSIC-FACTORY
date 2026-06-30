
data = {}

SCREEN_WIDTH = 240
SCREEN_HEIGHT = 136

Player.ROLL_TIME = 0.2

Player.SPEED = 54
Player.ROLL_SPEED = Player.SPEED * 1.8

Player.sprite = {
    stay = {
        i = 1,
        {id=257, T=-1},
    },
    run = {
        i = 1,
        {id=256, T=0.08},
        {id=257, T=0.08},
        {id=258, T=0.09},
        {id=259, T=0.08},
    },
    roll = {
        i = 1,
        {id=320, T=Player.ROLL_TIME / 6},
        {id=321, T=Player.ROLL_TIME / 6},
        {id=322, T=Player.ROLL_TIME / 6},
        {id=323, T=Player.ROLL_TIME / 6},
        {id=324, T=Player.ROLL_TIME / 6},
        {id=325, T=-1},
    },
}
Player.HITBOX = { -- обе границы включены
    x1 = 2, y1 = 2,
    x2 = 5, y2 = 6,
}
Player.HP = 6
Player.I_TIME = 0.6

FULL_HEART_SPRITE = 260
HALF_HEART_SPRITE = 261
EMPTY_HEART_SPRITE = 262


PistonEnemy.sprite = {
    warning = {
        i = 1,
        -- {id = 496, T = -1},
        {id = 465, T = -1},
    },
    prepare = {
        i = 1,
        -- {id = 497, T = -1},
        {id = 466, T = 0.05},
        {id = 467, T = -1},
    },
    attack = {
        i = 1,
        -- {id = 498, T = 0.05},
        -- {id = 499, T = 0.025},
        -- {id = 500, T = 0.025},
        -- {id = 501, T = 0.06},
        -- {id = 502, T = -1},
        {id = 468, T = -1},
    },
    release = {
        i = 1,
        -- {id = 503, T = 0.05},
        -- {id = 504, T = 0.05},
        -- {id = 496, T = -1},
        {id = 469, T = -1},
    },
}


Bullet.speed = 37