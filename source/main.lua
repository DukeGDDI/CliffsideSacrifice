-- main.lua

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"

local gfx = playdate.graphics

-- Import scripts (globals)
import "scripts/constants"
import "scripts/entities"
import "scripts/draw"

gfx.setBackgroundColor(gfx.kColorWhite)
gfx.setColor(gfx.kColorBlack)

Entities.initPendulum()

playdate.display.setRefreshRate(30)

function playdate.update()
    gfx.clear()

    -- Left / right pumping
    local pumpDir = 0
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        pumpDir = -1
    elseif playdate.buttonIsPressed(playdate.kButtonRight) then
        pumpDir = 1
    end

    -- Cut the last rope segment on B press (one cut per press)
    if playdate.buttonJustPressed(playdate.kButtonB) then
        Entities.cutSegment()
    end

    Entities.updatePendulum(pumpDir)
    Draw.drawPendulum(Entities.pendulum)

    playdate.timer.updateTimers()
end
