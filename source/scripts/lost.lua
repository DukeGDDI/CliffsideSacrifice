-- scripts/lost.lua
--
-- Screen shown when the CURRENT level is lost.
-- Press B to return to the main menu.

local gfx = playdate.graphics

Lost = {}

function Lost.enter()
    -- Any one-time setup (e.g., play a sad sound) can go here.
end

function Lost.update()
    -- No-op for now.
end

function Lost.draw()
    gfx.clear(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    local w, h = playdate.display.getWidth(), playdate.display.getHeight()
    gfx.drawTextAligned("LOST", w / 2, h / 2, kTextAlignment.center)
end

function Lost.AButtonDown()
    -- Future: maybe “Retry” from here.
end

function Lost.BButtonDown()
    App.setScreen(Menu)
end
