-- main.lua

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"

local gfx = playdate.graphics

import "scripts/constants"
import "scripts/entities"
import "scripts/draw"

-- Init
gfx.setBackgroundColor(gfx.kColorWhite)
gfx.setColor(gfx.kColorBlack)

Entities.initPendulum()

-- Optional: set a target FPS
playdate.display.setRefreshRate(30)

function playdate.update()
    gfx.clear()

    -- Simple input → pumpDir mapping for now
    local pumpDir = 0
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        pumpDir = -1
    elseif playdate.buttonIsPressed(playdate.kButtonRight) then
        pumpDir = 1
    end

    Entities.updatePendulum(pumpDir)
    Draw.drawPendulum(Entities.pendulum)

    playdate.timer.updateTimers()
end
