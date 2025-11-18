-- scripts/menu.lua
--
-- Main menu screen.
-- Menu options: "Start", "Resume", "Settings".
-- Uses MenuComponent for drawing.

import "scripts/game"
import "scripts/menu_component"

local gfx = playdate.graphics

Menu = Menu or {}

-- scripts/menu.lua

Menu.menu = {
    items                   = { "Start", "Resume", "Settings" },
    selectedIndex           = 1,
    backgroundColor         = gfx.kColorWhite,
    textColor               = gfx.kColorBlack,
    selectedTextColor       = gfx.kColorWhite,
    selectedBackgroundColor = gfx.kColorBlack,
    lineHeight              = 20,
    verticalOffset          = 0,
}


function Menu.enter()
    -- Reset selection whenever we come back to the menu
    Menu.menu.selectedIndex = Menu.menu.selectedIndex or 1
end

function Menu.update()
    -- Handle up/down navigation
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        MenuComponent.changeSelection(Menu.menu, -1)
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        MenuComponent.changeSelection(Menu.menu, 1)
    end
end

function Menu.draw()
    MenuComponent.draw(Menu.menu)
end

function Menu.AButtonDown()
    local idx   = Menu.menu.selectedIndex
    local label = Menu.menu.items[idx]

    if label == "Start" then
        -- Start a new game run
        Game.state = "playing"
        App.setScreen(Game)

    elseif label == "Resume" then
        -- Placeholder: no pause/save yet; no-op for now.
        -- Later you might App.setScreen(Game) if a game session exists.

    elseif label == "Settings" then
        App.setScreen(Settings)
    end
end

function Menu.BButtonDown()
    -- Back to splash screen
    App.setScreen(Splash)
end
