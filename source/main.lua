-- main.lua

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"

import "scripts/constants"
import "scripts/entities"
import "scripts/level"
import "scripts/draw"
import "scripts/camera"
import "scripts/game"

Game.init()

function playdate.update()
    Game.update()
end

function playdate.AButtonDown()
    Game.onAButtonDown()
end

function playdate.BButtonDown()
    Game.onBButtonDown()
end
