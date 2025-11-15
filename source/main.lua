-- main.lua

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"

local gfx = playdate.graphics

------------------------------------------------------------
-- Import script modules (define global tables)
-- IMPORTANT: constants must load before entities
------------------------------------------------------------
import "scripts/constants"
import "scripts/entities"
import "scripts/draw"

------------------------------------------------------------
-- Initialization
------------------------------------------------------------
gfx.setBackgroundColor(gfx.kColorWhite)
gfx.setColor(gfx.kColorBlack)

Entities.initPendulum()

playdate.display.setRefreshRate(30)

------------------------------------------------------------
-- Per-frame update
------------------------------------------------------------
function playdate.update()
    gfx.clear()

    --------------------------------------------------------
    -- Handle pumping input (continuous while held)
    --------------------------------------------------------
    local pumpDir = 0
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        pumpDir = -1
    elseif playdate.buttonIsPressed(playdate.kButtonRight) then
        pumpDir = 1
    end

    --------------------------------------------------------
    -- Physics update + drawing
    --------------------------------------------------------
    Entities.updatePendulum(pumpDir)
    Draw.drawPendulum(Entities.pendulum)

    playdate.timer.updateTimers()
end

------------------------------------------------------------
-- Button callbacks (one-shot actions)
------------------------------------------------------------
function playdate.BButtonDown()
    Entities.cutSegment()
end