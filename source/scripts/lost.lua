-- scripts/lost.lua
--
-- Lost screen.
-- Shows lost.png or lost_inverted.png depending on App.invertColors/App.invertColor.
-- Press B to return to Menu.

local gfx = playdate.graphics

Lost = Lost or {}

-- Load both variants once
local lostNormal   = gfx.image.new("assets/images/lost.png")
local lostInverted = gfx.image.new("assets/images/lost_inverted.png")

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

local function getLostImage()
    if isInverted() and lostInverted then
        return lostInverted
    end
    return lostNormal
end

function Lost.enter()
    -- If needed, reset timers or animations here.
end

function Lost.update()
    -- Static image, nothing to update yet.
end

function Lost.draw()
    local inverted = isInverted()
    local img = getLostImage()

    -- Clear background to theme (in case image isn't full screen)
    if inverted then
        gfx.clear(gfx.kColorBlack)
    else
        gfx.clear(gfx.kColorWhite)
    end

    if img then
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        img:draw(0, 0)  -- assumed full-screen
    else
        -- Fallback if images missing
        local w, h = playdate.display.getWidth(), playdate.display.getHeight()
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawTextAligned("LOST (missing image)", w/2, h/2, kTextAlignment.center)
    end
end

-- A does nothing right now (intentional)
function Lost.AButtonDown()
    -- no-op
end

function Lost.BButtonDown()
    App.setScreen(Menu)
end
