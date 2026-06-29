C0 = 0

require("Math")
require("Table")

require("Anime")
require("Player")
require("key")
require("Time")
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