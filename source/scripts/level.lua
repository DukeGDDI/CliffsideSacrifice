-- scripts/level.lua

if not Constants then
    import "scripts/constants"
end

Level = Level or {}

----------------------------------------------------------------
-- LEVEL DEFINITIONS (zero-indexed)
--
-- LEVEL SPACE:
--   (0,0) = center top of the level
--   X ∈ [-levelWidth/2, +levelWidth/2]
--   Y ∈ [0, levelHeight]
----------------------------------------------------------------

Level.levels = Level.levels or {}

Level.levels[0] = {
    -- Level dimensions in level space
    levelWidth  = 600,  -- e.g. 400 → X ∈ [-200, +200]
    levelHeight = 800,  -- taller than the screena

    -- Pendulum configuration for this level
    segmentLength = 50,
    segmentCount = 4,

    -- Peg list (first entry = starting pivot), in LEVEL SPACE
    pegs = {
        { x = 0, y =  50, type = "start" },
        { x = 80, y =  80, type = "standard" },
        { x = 70, y = 150, type = "standard" },
        { x = 150, y = 150, type = "standard" },
        { x = -80, y = 150, type = "standard" },
        { x = 0, y = 200, type = "standard" },
        { x = 150, y = 250, type = "standard" },
        { x = 100, y = 250, type = "standard" },
        { x = 0, y = 280, type = "standard" },
        { x = -50, y = 300, type = "standard" },
        { x = -100, y = 350, type = "standard" },
        { x = -150, y = 400, type = "standard" },
        { x = -200, y = 420, type = "standard" },
    },
}

----------------------------------------------------------------
-- API
----------------------------------------------------------------

-- Return the config table for level n (or nil if not defined)
function Level.getLevel(index)
    return Level.levels[index]
end
