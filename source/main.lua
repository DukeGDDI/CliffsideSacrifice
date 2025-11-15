-- main.lua

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"

local gfx = playdate.graphics

import "scripts/constants"
import "scripts/entities"
import "scripts/level"
import "scripts/draw"

gfx.setBackgroundColor(gfx.kColorWhite)
gfx.setColor(gfx.kColorBlack)

-- NEW: Level handles starting pivot and pegs
Level.apply()

playdate.display.setRefreshRate(30)

function playdate.update()
    gfx.clear()

    Draw.drawPegs(Entities.pegs)

    local pumpDir = 0
    if playdate.buttonIsPressed(playdate.kButtonLeft) then pumpDir = -1 end
    if playdate.buttonIsPressed(playdate.kButtonRight) then pumpDir = 1 end

    Entities.updatePendulum(pumpDir)
    Draw.drawPendulum(Entities.pendulum)

    playdate.timer.updateTimers()
end

function playdate.BButtonDown()
    Entities.cutSegment()
end

function playdate.AButtonDown()
    Entities.releasePivot()
end
