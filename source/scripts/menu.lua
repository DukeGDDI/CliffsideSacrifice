-- scripts/menu.lua

import "scripts/game"
import "scripts/menu_component"
import "scripts/level"

local gfx = playdate.graphics

Menu = Menu or {}

-- Load background variants once
local bgImageNormal   = gfx.image.new("assets/images/menubg.png")
local bgImageInverted = gfx.image.new("assets/images/menubg_inverted.png")

local function getBgImage()
    local inverted = false
    if App and App.invertColors ~= nil then
        inverted = App.invertColors
    end

    if inverted and bgImageInverted then
        return bgImageInverted
    end
    return bgImageNormal
end

----------------------------------------------------------------
-- Helper: figure out if the game is "fully won"
-- i.e., we are on the last level and Game.state == "won"
----------------------------------------------------------------
local function getMaxLevelIndex()
    local maxIndex = nil
    if Level and Level.levels then
        for idx, _ in pairs(Level.levels) do
            if type(idx) == "number" then
                if not maxIndex or idx > maxIndex then
                    maxIndex = idx
                end
            end
        end
    end
    return maxIndex or 0
end

local function isFullyWon()
    if not Game then return false end

    local curIndex = Game.currentLevelIndex or 0
    local maxIndex = getMaxLevelIndex()

    -- We consider "fully won" when you're on the last defined level
    -- and Game.state is "won".
    if Game.state == "won" and curIndex >= maxIndex then
        -- Also make sure there's no "next" level entry.
        if not (Level and Level.levels and Level.levels[curIndex + 1]) then
            return true
        end
    end

    return false
end

----------------------------------------------------------------
-- Menu model
----------------------------------------------------------------

Menu.menu = {
    items                   = {},  -- built dynamically
    selectedIndex           = 1,
    backgroundColor         = gfx.kColorWhite,
    textColor               = gfx.kColorBlack,
    selectedTextColor       = gfx.kColorWhite,
    selectedBackgroundColor = gfx.kColorBlack,
    lineHeight              = nil,
    itemGap                 = 4,
    paddingX                = 10,
    paddingY                = 3,
    verticalOffset          = 0,
    clearBackground         = false,   -- we draw the bg image ourselves
    x                       = 125,     -- center X of menu text (tweak to taste)
    y                       = 120,     -- top Y of first item
}

local function rebuildMenuItems()
    local items = {}

    -- Always have New Game
    table.insert(items, "New Game")

    -- Only show Restart Level if not fully won
    if not isFullyWon() then
        table.insert(items, "Restart Level")
    end

    -- Always have Settings
    table.insert(items, "Settings")

    Menu.menu.items = items

    -- Clamp selectedIndex into range
    local count = #items
    if count == 0 then
        Menu.menu.selectedIndex = 1
    else
        if Menu.menu.selectedIndex < 1 then
            Menu.menu.selectedIndex = 1
        elseif Menu.menu.selectedIndex > count then
            Menu.menu.selectedIndex = count
        end
    end
end

----------------------------------------------------------------
-- Screen lifecycle
----------------------------------------------------------------

function Menu.enter()
    rebuildMenuItems()
end

function Menu.update()
    -- In case Game.state changes while we're on the menu
    rebuildMenuItems()

    if playdate.buttonJustPressed(playdate.kButtonUp) then
        MenuComponent.changeSelection(Menu.menu, -1)
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        MenuComponent.changeSelection(Menu.menu, 1)
    end
end

function Menu.draw()
    -- Draw background image based on App.invertColors
    local img = getBgImage()
    if img then
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        img:draw(0, 0)
    else
        gfx.clear(gfx.kColorWhite)
    end

    -- Draw menu on top
    MenuComponent.draw(Menu.menu)
end

----------------------------------------------------------------
-- Input
----------------------------------------------------------------

function Menu.AButtonDown()
    local idx   = Menu.menu.selectedIndex
    local label = Menu.menu.items[idx]

    if label == "New Game" then
        -- Start from level 0, always.
        Game.state = "playing"
        Game.loadLevel(0)
        App.setScreen(Game)

    elseif label == "Restart Level" then
        -- Restart the CURRENT level, keeping Game.currentLevelIndex as-is.
        -- This is what you want after a loss.
        local idx = Game.currentLevelIndex or 0
        Game.state = "playing"
        Game.loadLevel(idx)
        App.setScreen(Game)

    elseif label == "Settings" then
        App.setScreen(Settings)
    end
end

function Menu.BButtonDown()
    App.setScreen(Splash)
end
