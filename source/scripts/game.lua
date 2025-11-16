-- scripts/game.lua

if not Constants then
    import "scripts/constants"
end
if not Level then
    import "scripts/level"
end
if not Entities then
    import "scripts/entities"
end
if not Draw then
    import "scripts/draw"
end
if not Camera then
    import "scripts/camera"
end

Game = Game or {}

----------------------------------------------------------------
-- GAME STATE
----------------------------------------------------------------

-- Zero-based level index
Game.currentLevelIndex = Game.currentLevelIndex or 0

----------------------------------------------------------------
-- INITIALIZATION
----------------------------------------------------------------

function Game.init()
    local gfx = playdate.graphics

    gfx.setBackgroundColor(gfx.kColorWhite)
    gfx.setColor(gfx.kColorBlack)

    playdate.display.setRefreshRate(30)

    -- For now: single level in Level.current / Level.levels[0]
    Game.loadLevel(Game.currentLevelIndex)
end

----------------------------------------------------------------
-- LEVEL MANAGEMENT
----------------------------------------------------------------

function Game.loadLevel(index)
    -- Default to current index if not provided
    if index == nil then
        index = Game.currentLevelIndex or 0
    end

    local cfg = Level.getLevel(index)
    if not cfg then
        return
    end

    Game.currentLevelIndex = index

    -- Configure entities from this level
    Entities.setPegs(cfg.pegs)
    Entities.initPendulum(cfg)

    -- Initialize camera using this level config + starting peg
    local startPeg = cfg.pegs and cfg.pegs[1] or nil
    if startPeg then
        local levelWidth  = cfg.levelWidth  or Constants.SCREEN_WIDTH
        local levelHeight = cfg.levelHeight or Constants.SCREEN_HEIGHT

        Camera.init(
            levelWidth,
            levelHeight,
            startPeg.x,
            startPeg.y
        )
    end
end

function Game.reloadLevel()
    Game.loadLevel(Game.currentLevelIndex)
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

    -- Update camera to follow current pivot
    local p = Entities.pendulum
    if p then
        local dt = 1 / 30 -- matches refresh rate
        Camera.update(dt, p.pivotX, p.pivotY)
    end

    -- Draw world
    Draw.drawPegs(Entities.pegs)
    Draw.drawPendulum(Entities.pendulum)

    -- Timers
    playdate.timer.updateTimers()
end

----------------------------------------------------------------
-- BUTTON HANDLERS (called from main.lua)
----------------------------------------------------------------

function Game.onAButtonDown()
    Entities.releasePivot()
end

function Game.onBButtonDown()
    Entities.cutSegment()
end
