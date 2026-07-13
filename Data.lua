
-- Bonus.T = Settings.bpm * 4 / 60.
-- Bonus.TIME_TO_LIVE = 6.7

function set_normal_constants()
    Player.SPEED = 43.5
    Settings.bpm = 840
    Bullet.speed = 24
end
set_normal_constants()

function set_speed_up_constants()
    Player.SPEED = 54
    Settings.bpm = 1500
    Bullet.speed = 38
end

Preview.SPEND = 'Spend money to restore the MUSIC FACTORY'
Preview.EARN = 'Earn money from the MUSIC FACTORY'
Preview.TEXT = {
    -- 'Music was once produced in MUSIC FACTORIES', 'like this one.', '',
    -- 'Then synthesizers became popular,', 'and MUSIC FACTORIES were no longer needed', ':-(','',
    'You bought an abandoned MUSIC FACTORY.','',
    'Bring the MUSIC FACTORY back to life', 'and produce music again!',
    '',
    '',
    Preview.EARN,
    Preview.SPEND,
    '',
    '',
    '','','','',
    '                <press Z to continue>',
}

WinScreen.SPEED_UP = '            <press X to play SPEED UP>'
WinScreen.YOUR_TIME = 'Your time:'
WinScreen.MY_TG = '                           @vcrocstudio'
WinScreen.TEXT = {
    'You restored the MUSIC FACTORY!', '',
    -- 'Beautiful music fills the air  :-D', '',
    'Your neighbors are happy!', '', 'They thank you for bringing','the MUSIC FACTORY back.',
    '',WinScreen.YOUR_TIME,'',
    '                <press Z to restart>',
    WinScreen.SPEED_UP,
    '',
    '',
    '                           Follow my tg :-)',
    WinScreen.MY_TG,
}

KEY_W = 23
KEY_A = 01
KEY_S = 19
KEY_D = 04

BEATS_IN_TACT = 16 -- мы все умрем если это изменить

SCREEN_WIDTH = 240
SCREEN_HEIGHT = 136

-- цвета
GOLD = 14
DARK_GOLD = 15
--

game.DEATH_TIME = 0.5
game.SURVIVE_TIME = 30--42

Player.ROLL_TIME = 0.25

Player.ROLL_SPEED = Player.SPEED * 2.3
Player.ROLL_COOLDOWN = 0.21
Player.ROLL_BUFFER = 0.0

-- начальная частота оплаты
Player.PAYMENT_FREQ = 0.15
-- коэффициент ускорения оплаты
Player.PAYMENT_ACC = 0.9

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
        {id=320, T=Player.ROLL_TIME / 7},
        {id=321, T=Player.ROLL_TIME / 7},
        {id=322, T=Player.ROLL_TIME / 7},
        {id=323, T=Player.ROLL_TIME / 7},
        {id=324, T=Player.ROLL_TIME / 7 * 2},
        {id=325, T=-1},
    },
}
Player.HITBOX = { -- обе границы включены
    x1 = 2, y1 = 2,
    x2 = 5, y2 = 6,
}
Player.HP = 6
Player.I_TIME = 0.6

Player.PAY_NOTE = Note:new(22, 0, 3, 0.34, 3)

Player.HURT_REACTION = 0.4 -- степень мерцания при получении урона

FULL_HEART_SPRITE = 260
HALF_HEART_SPRITE = 261
EMPTY_HEART_SPRITE = 262


Coin.sprite = {
    flip = {
        i = 1,
        {id=128, T=0.1},
        {id=129, T=0.05},
        {id=130, T=0.1},
        {id=129, T=0.05},
        -- {id=131, T=0.05},
        -- {id=132, T=0.05},
        -- {id=133, T=0.05},
        -- {id=134, T=0.05},
        -- {id=135, T=0.05},
    },
    static = {
        i = 1,
        {id=128, T=-1},
    }
}


PistonEnemy.sprite = {
    inactive = {
        i = 1,
        {id = 464, T = -1},
    },
    activating = {
        i = 1,
        {id = 469, T = 0.05},
        {id = 464, T = 0.05},
    },

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
PistonEnemy.HITBOX = {x1=1, y1=1, x2=6, y2=7}
PistonEnemy.INTERBOX = {x1=-4, y1=-3, x2=13, y2=17} 
PistonEnemy.COUNT_BULLETS = 6
-- hitbox for INTERaction 🤪


CircleEnemy.R = 5
CircleEnemy.PULLBACK_DISTANCE = 2
CircleEnemy.HITBOX = {x=0, y=0, r=CircleEnemy.R, is_circle=true}
-- CircleEnemy.INTERBOX = {x=0, y=0, r=CircleEnemy.R+6, is_circle=true}
CircleEnemy.INTERBOX = {x1=-(CircleEnemy.R+4), y1=-(CircleEnemy.R+4), x2=CircleEnemy.R+4, y2=CircleEnemy.R+4}
-- CircleEnemy.PRERELEASE_TIME = 0.08 -- задержка появления

-- Discoball.R = 8
-- Discoball.COLOR = 4
-- Discoball.INTERBOX = {x=0, y=0, r=Discoball.R+5, is_circle=true}

-- Laser.ATTACK_TIME = 0.6

Enemy.default_cost = 10
Enemy.MONEY_TIME = 0.5
Enemy.MONEY_COLOR = DARK_GOLD
Enemy.COST_COLOR = 7
Enemy.FEAR_TIME = 0.76

Chest.sprite = {
    static = {
        i = 1,
        {id=480, T=-1},
    },
    dieing = {
        i = 1,
        {id=482, T=-1},
    },
}
Chest.HP = {small=25, big=25}
Chest.HITBOX = {
    x1 = 0,
    y1 = 2,
    x2 = 15,
    y2 = 15,
}
Chest.DIE_T = 0.11
-- начальная частота выдачи награды
Chest.REWARD_FREQ = 0.12
-- коэффициент ускорения
Chest.REWARD_ACC = 0.75
Chest.REWARD = 25

Sheet.load()


