-- scripts/splash.lua
--
-- Splash screen.
-- Draws the splash image (assets/images/splash.png).
-- Press A or B to go to the main menu (Menu screen).

local gfx = playdate.graphics

Splash = Splash or {}

-- Load once
local splashImage = gfx.image.new("assets/images/splash2.png")

function Splash.enter()
    -- Any setup when entering the splash can go here.
end

function Splash.update()
    -- No-op for now (static screen).
end

function Splash.draw()
    -- If the image matches the 400x240 display, just draw at 0,0
    gfx.clear(gfx.kColorWhite)

    if splashImage then
        -- Use normal copy mode so the bitmap’s dithering looks correct
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        splashImage:draw(0, 0)
    else
        -- Fallback: simple text if image fails to load
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
        local w, h = playdate.display.getWidth(), playdate.display.getHeight()
        gfx.drawTextAligned("SPLASH (missing image)", w / 2, h / 2, kTextAlignment.center)
    end
end

function Splash.AButtonDown()
    App.setScreen(Menu)
end

function Splash.BButtonDown()
    App.setScreen(Menu)
end
