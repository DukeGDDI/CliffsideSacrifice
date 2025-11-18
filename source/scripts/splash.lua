-- scripts/splash.lua
--
-- Initial splash screen.
-- Press A or B to go to the main menu (Menu screen).

local gfx = playdate.graphics

Splash = {}

function Splash.enter()
    -- Any setup when entering the splash can go here (timers, etc).
end

function Splash.update()
    -- No-op for now (static screen).
end

function Splash.draw()
    gfx.clear(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    local w, h = playdate.display.getWidth(), playdate.display.getHeight()
    gfx.drawTextAligned("SPLASH", w / 2, h / 2, kTextAlignment.center)
end

function Splash.AButtonDown()
    App.setScreen(Menu)
end

function Splash.BButtonDown()
    App.setScreen(Menu)
end
