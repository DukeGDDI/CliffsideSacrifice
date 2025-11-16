-- main.lua

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"

local gfx = playdate.graphics

import "scripts/constants"
import "scripts/entities"
import "scripts/level"
import "scripts/draw"
import "scripts/game"
-- (camera.lua can be imported later when we wire it up)
-- import "scripts/camera"

-- Initialize the game (colors, frame rate, first level)
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
