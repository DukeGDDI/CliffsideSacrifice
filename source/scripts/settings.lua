-- scripts/settings.lua

import "scripts/game"
import "scripts/menu_component"

local gfx = playdate.graphics

Settings = Settings or {}

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

-- Defaults
if App and App.invertColors == nil then
    App.invertColors = false
end
if Game.soundOn == nil then
    Game.soundOn = true
end

local function buildItems()
    local invertLabel = (App and App.invertColors) and "Invert Colors: On" or "Invert Colors: Off"
    local soundLabel  = Game.soundOn and "Sound: On" or "Sound: Off"
    return { invertLabel, soundLabel }
end

Settings.menu = {
    items                   = buildItems(),
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
    x                       = 125,
    y                       = 120,
}

function Settings.enter()
    Settings.menu.selectedIndex = Settings.menu.selectedIndex or 1
end

function Settings.update()
    Settings.menu.items = buildItems()

    if playdate.buttonJustPressed(playdate.kButtonUp) then
        MenuComponent.changeSelection(Settings.menu, -1)
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        MenuComponent.changeSelection(Settings.menu, 1)
    end
end

function Settings.draw()
    -- Draw background image based on App.invertColors
    local img = getBgImage()
    if img then
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        img:draw(0, 0)
    else
        gfx.clear(gfx.kColorWhite)
    end

    Settings.menu.items = buildItems()
    MenuComponent.draw(Settings.menu)
end

function Settings.AButtonDown()
    local idx = Settings.menu.selectedIndex

    if idx == 1 then
        -- Toggle invert flag
        if App then
            App.invertColors = not (App.invertColors or false)
        end
        Game.invertColors = App and App.invertColors or false

    elseif idx == 2 then
        Game.soundOn = not Game.soundOn
    end
end

function Settings.BButtonDown()
    App.setScreen(Menu)
end
