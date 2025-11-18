-- scripts/won.lua
--
-- Screen shown when ALL levels have been won.
-- Press B to return to the main menu.

local gfx = playdate.graphics

Won = {}

function Won.enter()
    -- Any one-time effects for "full victory" can go here.
end

function Won.update()
    -- No-op for now.
end

function Won.draw()
    gfx.clear(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    local w, h = playdate.display.getWidth(), playdate.display.getHeight()
    gfx.drawTextAligned("WON (ALL LEVELS)", w / 2, h / 2, kTextAlignment.center)
end

function Won.AButtonDown()
    -- Could also send back to Menu if desired later.
end

function Won.BButtonDown()
    App.setScreen(Menu)
end
