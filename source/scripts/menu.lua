-- scripts/menu.lua
--
-- Main menu screen.
-- Menu options conceptually: "Start", "Resume", "Settings"
-- For this first pass we just render "MAIN MENU" centered, but
-- A/B are wired according to the spec.

import "scripts/game"

local gfx = playdate.graphics

Menu = {}

Menu.items = { "Start", "Resume", "Settings" }
Menu.selectedIndex = 1   -- Future: use up/down to change this

function Menu.enter()
    -- Reset selection when entering the menu if desired
    Menu.selectedIndex = 1
end

function Menu.update()
    -- Future: handle D-pad up/down to change Menu.selectedIndex.
end

function Menu.draw()
    gfx.clear(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    local w, h = playdate.display.getWidth(), playdate.display.getHeight()
    gfx.drawTextAligned("MAIN MENU", w / 2, h / 2, kTextAlignment.center)
end

function Menu.AButtonDown()
    local idx   = Menu.selectedIndex
    local label = Menu.items[idx]

    if label == "Start" then
        -- Start a new run: ensure Game.state is ready
        Game.state = "playing"
        App.setScreen(Game)

    elseif label == "Resume" then
        -- For now a no-op (pause/save not implemented yet).
        -- You could also choose to App.setScreen(Game) here later.

    elseif label == "Settings" then
        App.setScreen(Settings)
    end
end

function Menu.BButtonDown()
    -- Return to splash screen
    App.setScreen(Splash)
end
