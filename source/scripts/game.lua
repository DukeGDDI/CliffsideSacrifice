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

local gfx = playdate.graphics

-- Global Game table (never local, never returned)
Game = Game or {}

-- Zero-indexed current level
Game.currentLevelIndex  = Game.currentLevelIndex or 0
Game.currentLevelConfig = Game.currentLevelConfig or nil

----------------------------------------------------------------
-- INIT
----------------------------------------------------------------
function Game.init()
    -- Basic graphics setup
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.setColor(gfx.kColorWhite)
    playdate.display.setRefreshRate(30)

    -- Load the initial level
    Game.loadLevel(Game.currentLevelIndex)

    -- print("skyImage:", Draw.skyImage)
    -- print("groundImage:", Draw.groundImage)

end

----------------------------------------------------------------
-- LEVEL LOADING
----------------------------------------------------------------

-- Reload the current level
function Game.reloadLevel()
    Game.loadLevel(Game.currentLevelIndex)
end

-- Load a level by index (zero-based)
function Game.loadLevel(index)
    local cfg = Level.getLevel(index)
    if not cfg then
        print(string.format("[Game] No level config for index %s", tostring(index)))
        return
    end

    Game.currentLevelIndex  = index
    Game.currentLevelConfig = cfg

    ----------------------------------------------------------------
    -- Configure pegs
    ----------------------------------------------------------------
    if cfg.pegs then
        Entities.setPegs(cfg.pegs)
    else
        Entities.setPegs(nil)
    end

    ----------------------------------------------------------------
    -- Choose the start peg
    --
    -- Rule:
    --   * Prefer the first peg whose type == "start"
    --   * Fallback to the first peg in the list if none are marked
    ----------------------------------------------------------------
    local startPeg = nil
    local pegs     = cfg.pegs

    if pegs and #pegs > 0 then
        for i = 1, #pegs do
            local peg = pegs[i]
            if peg.type == "start" then
                startPeg = peg
                break
            end
        end

        if not startPeg then
            startPeg = pegs[1]
        end
    end

    ----------------------------------------------------------------
    -- Initialize pendulum and camera
    ----------------------------------------------------------------
    -- Pendulum initialization uses Level.getLevel + Game.currentLevelIndex
    Entities.initPendulum()

    local startX = Constants.PIVOT_X
    local startY = Constants.PIVOT_Y

    if startPeg then
        startX = startPeg.x
        startY = startPeg.y
    end

    Camera.init(
        cfg.levelWidth  or (Constants.SCREEN_WIDTH * 2),
        cfg.levelHeight or (Constants.SCREEN_HEIGHT * 2),
        startX,
        startY
    )
end

----------------------------------------------------------------
-- UPDATE
----------------------------------------------------------------
function Game.update()
    gfx.clear()

    -- Input: left/right → pump direction
    local leftPressed  = playdate.buttonIsPressed(playdate.kButtonLeft)
    local rightPressed = playdate.buttonIsPressed(playdate.kButtonRight)

    local pumpDir = 0
    if leftPressed and not rightPressed then
        pumpDir = -1
    elseif rightPressed and not leftPressed then
        pumpDir = 1
    end

    -- Update rope / pendulum physics
    Entities.updatePendulum(pumpDir)

    -- Camera follows the current pivot of the pendulum
    local p = Entities.pendulum
    if p then
        Camera.update(1 / 30, p.pivotX, p.pivotY)
    else
        Camera.update(1 / 30)
    end

    -- Draw background cliff layers
    Draw.drawCliffTop()
    Draw.drawCliffBase()

    -- Draw pegs + rope
    Draw.drawPegs(Entities.pegs)
    Draw.drawPendulum(Entities.pendulum)

    -- Update timers (for future use)
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
