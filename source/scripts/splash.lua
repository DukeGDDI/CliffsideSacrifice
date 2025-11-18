-- scripts/splash.lua
--
-- Splash screen.
-- Draws splash.png or splash_inverted.png depending on App.invertColors/App.invertColor.
-- Press A or B to go to the main menu (Menu screen).

local gfx = playdate.graphics

Splash = Splash or {}

-- Load both variants once
local splashNormal   = gfx.image.new("assets/images/splash2.png")
local splashInverted = gfx.image.new("assets/images/splash2_inverted.png")

local function isInverted()
    if not App then return false end
    if App.invertColors ~= nil then
        return App.invertColors
    end
    if App.invertColor ~= nil then
        return App.invertColor
    end
    return false
end

local function getSplashImage()
    local inverted = isInverted()
    if inverted and splashInverted then
        return splashInverted
    end
    return splashNormal
end

function Splash.enter()
    -- Any future setup for splash can go here.
end

function Splash.update()
    -- Static splash for now.
end

function Splash.draw()
    local inverted = isInverted()
    local img = getSplashImage()

    -- Clear background to match theme in case image isn't full-screen
    if inverted then
        gfx.clear(gfx.kColorBlack)
    else
        gfx.clear(gfx.kColorWhite)
    end

    if img then
        gfx.setImageDrawMode(gfx.kDrawModeCopy)

        -- Assume full-screen 400x240; if not, this still draws from top-left.
        img:draw(0, 0)
    else
        -- Fallback text if images fail to load
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
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
