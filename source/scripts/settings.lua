-- scripts/settings.lua
--
-- Settings screen.
-- Conceptual options:
--   - "Invert Colors"
--   - "Sound [On/Off]"
-- For this pass we only show "SETTINGS" centered, but we do toggle
-- Game.invertColors and Game.soundOn when A is pressed.

import "scripts/game"

local gfx = playdate.graphics

Settings = {}

Settings.options = { "invert", "sound" }
Settings.selectedIndex = 1

-- Ensure defaults exist
if Game.invertColors == nil then
    Game.invertColors = false
end
if Game.soundOn == nil then
    Game.soundOn = true
end

function Settings.enter()
    Settings.selectedIndex = 1
end

function Settings.update()
    -- Future: use D-pad to move between "invert" and "sound".
end

function Settings.draw()
    gfx.clear(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    local w, h = playdate.display.getWidth(), playdate.display.getHeight()
    gfx.drawTextAligned("SETTINGS", w / 2, h / 2, kTextAlignment.center)
end

function Settings.AButtonDown()
    local opt = Settings.options[Settings.selectedIndex]

    if opt == "invert" then
        Game.invertColors = not Game.invertColors

    elseif opt == "sound" then
        Game.soundOn = not Game.soundOn
    end
end

function Settings.BButtonDown()
    -- Back to main menu
    App.setScreen(Menu)
end
