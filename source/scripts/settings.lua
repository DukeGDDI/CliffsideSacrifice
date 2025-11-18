-- scripts/settings.lua
--
-- Settings screen.
-- Conceptual options:
--   1) Invert Colors
--   2) Sound [On/Off]
--
-- Uses MenuComponent for drawing. Labels update dynamically
-- based on App.invertColor and Game.soundOn.

import "scripts/game"
import "scripts/menu_component"

local gfx = playdate.graphics

Settings = Settings or {}

-- Ensure defaults exist
if App and App.invertColor == nil then
    App.invertColor = false
end
if Game.soundOn == nil then
    Game.soundOn = true
end


-- scripts/settings.lua

Settings.menu = {
    items                   = {},  -- filled dynamically each frame
    selectedIndex           = 1,
    backgroundColor         = gfx.kColorWhite,
    textColor               = gfx.kColorBlack,
    selectedTextColor       = gfx.kColorWhite,
    selectedBackgroundColor = gfx.kColorBlack,
    lineHeight              = 20,
    verticalOffset          = 0,
}


local function buildItems()
    local invertLabel = App.invertColor and "Invert Colors: On" or "Invert Colors: Off"
    local soundLabel  = Game.soundOn    and "Sound: On"         or "Sound: Off"
    return { invertLabel, soundLabel }
end

function Settings.enter()
    Settings.menu.selectedIndex = Settings.menu.selectedIndex or 1
end

function Settings.update()
    -- Rebuild labels each frame so they reflect current values
    Settings.menu.items = buildItems()

    -- Handle up/down navigation
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        MenuComponent.changeSelection(Settings.menu, -1)
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        MenuComponent.changeSelection(Settings.menu, 1)
    end
end

function Settings.draw()
    -- Ensure items are up-to-date before drawing
    Settings.menu.items = buildItems()
    MenuComponent.draw(Settings.menu)
end

function Settings.AButtonDown()
    local idx = Settings.menu.selectedIndex

    if idx == 1 then
        -- Toggle invert colors
        App.invertColor = not App.invertColor

    elseif idx == 2 then
        -- Toggle sound
        Game.soundOn = not Game.soundOn
    end
end

function Settings.BButtonDown()
    -- Back to main menu
    App.setScreen(Menu)
end
