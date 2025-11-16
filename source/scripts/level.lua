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
    levelWidth  = Constants.SCREEN_WIDTH,  -- e.g. 400 → X ∈ [-200, +200]
    levelHeight = 800,                     -- taller than the screen

    -- Pendulum configuration for this level
    pendulumLength = Constants.PENDULUM_LENGTH_DEFAULT,
    segmentCount   = Constants.PENDULUM_SEGMENT_COUNT,

    -- Peg list (first entry = starting pivot), in LEVEL SPACE
    pegs = {
        {
            x = 0,
            y = 50,
            radius = Constants.PEG_DEFAULT_RADIUS,
            type   = "start",
        },

        { x = 80, y =  80, radius = Constants.PEG_DEFAULT_RADIUS, type = "standard" },
        { x = 70, y = 150, radius = Constants.PEG_DEFAULT_RADIUS, type = "standard" },
    },
}

----------------------------------------------------------------
-- API
----------------------------------------------------------------

-- Return the config table for level n (or nil if not defined)
function Level.getLevel(index)
    return Level.levels[index]
end
