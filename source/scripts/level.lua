-- scripts/level.lua

if not Constants then
    import "scripts/constants"
end

Level = Level or {}

----------------------------------------------------------------
-- LEVEL DEFINITIONS
--
-- For now we only have level 1. Later you can add more entries
-- into Level.levels[2], [3], etc.
----------------------------------------------------------------

Level.levels = {

    [1] = {
        -- Level dimensions in world space (top-left origin for now).
        levelWidth  = Constants.SCREEN_WIDTH,  -- 400
        levelHeight = 800,                     -- example: taller than screen

        -- Pendulum configuration for this level
        pendulumLength = Constants.PENDULUM_LENGTH_DEFAULT,
        segmentCount   = Constants.PENDULUM_SEGMENT_COUNT,

        -- Peg list (first entry = starting pivot)
        pegs = {
            {
                x = Constants.SCREEN_WIDTH / 2,
                y = 50,
                radius = Constants.PEG_DEFAULT_RADIUS,
                type = "start",
            },

            { x = 280, y = 80,  radius = Constants.PEG_DEFAULT_RADIUS, type = "standard" },
            { x = 270, y = 150, radius = Constants.PEG_DEFAULT_RADIUS, type = "standard" },
        },
    },

    -- [2] = { ... another level ... },
}

----------------------------------------------------------------
-- API
----------------------------------------------------------------

-- Return the config table for level n (or nil if not defined)
function Level.getLevel(n)
    return Level.levels[n]
end

-- Apply a specific level index:
--  - stores current index
--  - configures Entities from that level
function Level.apply(index)
    local cfg = Level.getLevel(index)
    if not cfg then
        -- If index is invalid, do nothing for now
        return
    end

    Level.currentIndex = index
    Level.current      = cfg

    Entities.setPegs(cfg.pegs)
    Entities.initPendulum()
end
