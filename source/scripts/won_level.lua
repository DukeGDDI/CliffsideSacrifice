-- scripts/won-level.lua
--
-- Screen shown when the *current* level has been won.
-- Press B to return to the main menu.

local gfx = playdate.graphics

WonLevel = {}

function WonLevel.enter()
    -- Could capture the last level index here if needed.
end

function WonLevel.update()
    -- No-op for now.
end

function WonLevel.draw()
    gfx.clear(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    local w, h = playdate.display.getWidth(), playdate.display.getHeight()
    gfx.drawTextAligned("WON LEVEL", w / 2, h / 2, kTextAlignment.center)
end

function WonLevel.AButtonDown()
    -- Future: maybe "Next Level" via A.
end

function WonLevel.BButtonDown()
    App.setScreen(Menu)
end
