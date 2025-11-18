-- main.lua
--
-- Root application entry point.
--  - Sets up App.currentScreen
--  - Delegates update/draw/input to whatever screen is active
--  - If the current screen is Game, it looks at Game.state to transition
--    to Won/Lost screens.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/timer"

-- Core game systems (you likely already had these imports somewhere)
import "scripts/constants"
import "scripts/menu_component"
import "scripts/camera"
import "scripts/entities"
import "scripts/level"
import "scripts/draw"
import "scripts/game"

local gfx = playdate.graphics

------------------------------------------------------------
-- Global App state
------------------------------------------------------------

App = App or {}

-- Currently active screen (Splash, Menu, Game, Settings, Won, WonLevel, Lost)
App.currentScreen = nil
App.invertColor   = App.invertColor or false  -- default

-- Helper to switch screens by table, not by name
function App.setScreen(screen)
    App.currentScreen = screen
    if screen and screen.enter then
        screen.enter()
    end
end

-- Screen modules
import "scripts/splash"
import "scripts/menu"
import "scripts/settings"
import "scripts/won"
import "scripts/won_level"
import "scripts/lost"

------------------------------------------------------------
-- Init
------------------------------------------------------------

-- Initialize the core Game module once
if Game.init then
    Game.init()
end

-- Ensure Game.state has a default
Game.state = Game.state or "playing"

-- Start at the splash screen
App.setScreen(Splash)

------------------------------------------------------------
-- Playdate callbacks
------------------------------------------------------------

function playdate.update()
    playdate.timer.updateTimers()

    local screen = App.currentScreen
    if screen then
        if screen.update then
            screen.update()
        end
        if screen.draw then
            screen.draw()
        end

        -- If the current screen *is* the Game, use Game.state to route
        if screen == Game then
            if Game.state == "won" then
                -- For now, treat all wins as "won current level"
                App.setScreen(WonLevel)
            elseif Game.state == "lost" then
                App.setScreen(Lost)
            end
        end
    else
        -- Safety fallback
        gfx.clear(gfx.kColorBlack)
    end
end

function playdate.AButtonDown()
    local screen = App.currentScreen
    if screen and screen.AButtonDown then
        screen.AButtonDown()
    end
end

function playdate.BButtonDown()
    local screen = App.currentScreen
    if screen and screen.BButtonDown then
        screen.BButtonDown()
    end
end

-- Allow Game to be used as App.currentScreen by providing
-- AButtonDown / BButtonDown methods that delegate to the existing handlers.

function Game.AButtonDown()
    if Game.onAButtonDown then
        Game.onAButtonDown()
    end
end

function Game.BButtonDown()
    if Game.onBButtonDown then
        Game.onBButtonDown()
    end
end

