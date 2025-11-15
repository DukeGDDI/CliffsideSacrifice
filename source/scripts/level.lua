-- scripts/level.lua

-- Make sure Constants exists if this file is loaded directly
if not Constants then
    import "scripts/constants"
end

Level = Level or {}

----------------------------------------------------------------
-- ALL pivots are pegs.
-- The FIRST peg is the starting pivot.
----------------------------------------------------------------

Level.current = {

    -- Pendulum configuration for this level
    pendulumLength = Constants.PENDULUM_LENGTH_DEFAULT,
    segmentCount   = Constants.PENDULUM_SEGMENT_COUNT,

    -- Peg list (first entry = starting pivot)
    pegs = {
        {
            x = Constants.SCREEN_WIDTH / 2,
            y = 50,
            radius = Constants.PEG_DEFAULT_RADIUS,
            type = "start"
        },

        { x = 280, y = 80,  radius = Constants.PEG_DEFAULT_RADIUS, type = "standard" },
        { x = 120, y = 130, radius = Constants.PEG_DEFAULT_RADIUS, type = "standard" },
    },
}

function Level.getCurrent()
    return Level.current
end

-- Apply the current level configuration
function Level.apply()
    local cfg = Level.current

    Entities.setPegs(cfg.pegs)
    Entities.initPendulum() -- now uses peg #1 as pivot
end
