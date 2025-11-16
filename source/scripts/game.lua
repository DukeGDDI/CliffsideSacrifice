-- scripts/game.lua

if not Level then
    import "scripts/level"
end
if not Entities then
    import "scripts/entities"
end
if not Draw then
    import "scripts/draw"
end

Game = Game or {}

----------------------------------------------------------------
-- GAME STATE
----------------------------------------------------------------

-- Which level index we are currently on (1-based)
Game.currentLevelIndex = Game.currentLevelIndex or 1

----------------------------------------------------------------
-- INITIALIZATION
----------------------------------------------------------------

function Game.init()
    local gfx = playdate.graphics

    -- Visual setup
    gfx.setBackgroundColor(gfx.kColorWhite)
    gfx.setColor(gfx.kColorBlack)

    -- Frame rate
    playdate.display.setRefreshRate(30)

    -- Load the starting level
    Game.loadLevel(Game.currentLevelIndex)
end

----------------------------------------------------------------
-- LEVEL MANAGEMENT
----------------------------------------------------------------

-- Load a specific level index.
-- This calls into Level.apply(index), which configures Entities.
function Game.loadLevel(index)
    if not index then
        index = Game.currentLevelIndex or 1
    end

    local cfg = Level.getLevel(index)
    if not cfg then
        -- Invalid index; do nothing for now
        return
    end

    Game.currentLevelIndex = index
    Level.apply(index)
end

function Game.reloadLevel()
    Game.loadLevel(Game.currentLevelIndex)
end

function Game.nextLevel()
    local nextIndex = (Game.currentLevelIndex or 1) + 1
    if Level.getLevel(nextIndex) then
        Game.loadLevel(nextIndex)
    else
        -- No next level defined yet; just reload current
        Game.reloadLevel()
    end
end

----------------------------------------------------------------
-- MAIN UPDATE LOOP (called from main.lua)
----------------------------------------------------------------

function Game.update()
    local gfx = playdate.graphics
    gfx.clear()

    -- Input → pumpDir (-1 = left, +1 = right, 0 = none)
    local pumpDir = 0
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        pumpDir = -1
    elseif playdate.buttonIsPressed(playdate.kButtonRight) then
        pumpDir = 1
    end

    -- Update rope / pendulum / entities
    Entities.updatePendulum(pumpDir)

    -- Draw the pegs
    Draw.drawPegs(Entities.pegs)

    -- Draw world
    Draw.drawPendulum(Entities.pendulum)

    -- Timers
    playdate.timer.updateTimers()
end

----------------------------------------------------------------
-- BUTTON HANDLERS (called from main.lua)
----------------------------------------------------------------

function Game.onAButtonDown()
    -- For now: release from pivot
    Entities.releasePivot()
end

function Game.onBButtonDown()
    -- For now: cut the last rope segment
    Entities.cutSegment()
end
