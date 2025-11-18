-- scripts/menu.lua

import "scripts/game"
import "scripts/menu_component"

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

Menu.menu = {
    items                   = { "New Game", "Restart Level", "Settings" },
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

function Menu.enter()
    Menu.menu.selectedIndex = Menu.menu.selectedIndex or 1
end

function Menu.update()
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

function Menu.AButtonDown()
    local idx   = Menu.menu.selectedIndex
    local label = Menu.menu.items[idx]

    if label == "Start" then
        Game.state = "playing"
        App.setScreen(Game)

    elseif label == "Resume" then
        -- no-op for now

    elseif label == "Settings" then
        App.setScreen(Settings)
    end
end

function Menu.BButtonDown()
    App.setScreen(Splash)
end
