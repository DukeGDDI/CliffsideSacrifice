-- scripts/won-level.lua
--
-- WonLevel screen.
-- Menu-style screen shown when the CURRENT level is won.
-- Items:
--   - "Next Level" : load and start the next level
--   - "Pause"      : no-op for now
--
-- Uses MenuComponent and menubg / menubg_inverted for background.

import "scripts/game"
import "scripts/level"
import "scripts/menu_component"

local gfx = playdate.graphics

WonLevel = WonLevel or {}

-- Background art (reuse menu background)
local bgImageNormal   = gfx.image.new("assets/images/menubg.png")
local bgImageInverted = gfx.image.new("assets/images/menubg_inverted.png")

local function isInverted()
    if not App then return false end
    if App.invertColors ~= nil then
        return App.invertColors
    elseif App.invertColor ~= nil then
        return App.invertColor
    end
    return false
end

local function getBgImage()
    if isInverted() and bgImageInverted then
        return bgImageInverted
    end
    return bgImageNormal
end

-- Menu configuration
WonLevel.menu = {
    items                   = { "Next Level", "Pause" },
    selectedIndex           = 1,
    backgroundColor         = gfx.kColorWhite,
    textColor               = gfx.kColorBlack,
    selectedTextColor       = gfx.kColorWhite,
    selectedBackgroundColor = gfx.kColorBlack,
    lineHeight              = nil,   -- derive from text + padding
    itemGap                 = 4,
    paddingX                = 6,
    paddingY                = 3,
    verticalOffset          = 0,
    clearBackground         = false, -- we draw bg image ourselves
    x                       = 220,   -- center X for menu text (tweak to taste)
    y                       = 120,   -- top Y of first item
    cornerRadius            = 6,     -- used by MenuComponent for rounded corners
}

-- Called when we first enter the WonLevel screen
function WonLevel.enter()
    -- Check for existence of "next level" BEFORE we ever draw.
    local curIndex  = Game.currentLevelIndex or 0
    local nextIndex = curIndex + 1

    if not (Level and Level.levels and Level.levels[nextIndex]) then
        -- No more levels defined -> go straight to full Won screen
        if Won then
            App.setScreen(Won)
        else
            -- Fallback to main menu if Won screen isn't present
            App.setScreen(Menu)
        end
        return
    end

    -- We *do* have another level, so show the won-level menu
    WonLevel.menu.selectedIndex = 1
end

function WonLevel.update()
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        MenuComponent.changeSelection(WonLevel.menu, -1)
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        MenuComponent.changeSelection(WonLevel.menu, 1)
    end
end

function WonLevel.draw()
    -- If enter() redirected us to Won or Menu, this draw won't be called.

    -- Draw background image based on invert setting
    local img = getBgImage()
    if img then
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        img:draw(0, 0)
    else
        gfx.clear(gfx.kColorWhite)
    end

    -- Draw menu on top
    MenuComponent.draw(WonLevel.menu)
end

local function goToNextLevel()
    local curIndex  = Game.currentLevelIndex or 0
    local nextIndex = curIndex + 1

    -- We already guard in enter(), but keep this defensive:
    if not (Level and Level.levels and Level.levels[nextIndex]) then
        if Won then
            App.setScreen(Won)
        else
            App.setScreen(Menu)
        end
        return
    end

    Game.currentLevelIndex = nextIndex
    Game.state = "playing"
    Game.loadLevel(nextIndex)
    App.setScreen(Game)
end

function WonLevel.AButtonDown()
    local idx   = WonLevel.menu.selectedIndex
    local label = WonLevel.menu.items[idx]

    if label == "Next Level" then
        goToNextLevel()
    elseif label == "Pause" then
        -- No-op for now; could go to a pause/options screen later.
    end
end

function WonLevel.BButtonDown()
    -- From won-level, B returns to main menu
    App.setScreen(Menu)
end
