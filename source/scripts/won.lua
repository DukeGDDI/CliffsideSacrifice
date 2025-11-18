-- scripts/won.lua
--
-- Won screen.
-- Shows won.png or won_inverted.png depending on App.invertColors/App.invertColor.
-- Press B to return to Menu.

local gfx = playdate.graphics

Won = Won or {}

-- Load image variants
local wonNormal   = gfx.image.new("assets/images/won.png")
local wonInverted = gfx.image.new("assets/images/won_inverted.png")

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

local function getWonImage()
    if isInverted() and wonInverted then
        return wonInverted
    end
    return wonNormal
end

function Won.enter()
    -- Any per-entry state could go here later (like sound or animation).
end

function Won.update()
    -- Static for now.
end

function Won.draw()
    local inverted = isInverted()
    local img = getWonImage()

    -- Clear background to match theme (safety in case image isn't full-screen)
    if inverted then
        gfx.clear(gfx.kColorBlack)
    else
        gfx.clear(gfx.kColorWhite)
    end

    if img then
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        img:draw(0, 0)
    else
        -- fallback text if images missing
        local w, h = playdate.display.getWidth(), playdate.display.getHeight()
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawTextAligned("WON (missing image)", w/2, h/2, kTextAlignment.center)
    end
end

function Won.AButtonDown()
    -- No-op
end

function Won.BButtonDown()
    App.setScreen(Menu)
end
