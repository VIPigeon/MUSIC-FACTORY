
C0 = 0

require("Math")
require("Table")
require("Time")

require("Anime")
require("TextWithOutline")
require("Collision")
require("Settings")
require("ChangeScreenAnimator")
require("RestartDialog")
require("Preview")
require("WinScreen")

-- Невероятно душные модули. Я их ненавижу
require("Sheet")
require("Generation")
--

require("Player")
require("Enemies") -- все противники в одном файле ⚛️
require("Director") -- Дирижер 
require("key")
require("Bullet")
require("Game")

-- Устанавливает все константы, привязанные к классам
-- Поэтому реквайрится в конце 🤌
require("Data")

game.init()
function TIC()
    cls(C0)
    Time.update()
    
    game.update()
    game.draw()
end