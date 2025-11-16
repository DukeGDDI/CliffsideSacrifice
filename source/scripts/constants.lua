-- scripts/constants.lua

-- Global constants table (never local, never returned)
Constants = Constants or {}

-- Playdate screen dimensions
Constants.SCREEN_WIDTH  = 400
Constants.SCREEN_HEIGHT = 240

-- Rope / pendulum tuning
Constants.PENDULUM_SEGMENT_COUNT  = 4        -- number of segments in the rope
Constants.PENDULUM_SEGMENT_LENGTH = 10

-- Verlet physics tuning
Constants.PENDULUM_GRAVITY        = 0.25    -- per-frame gravity for Verlet
Constants.PENDULUM_DAMPING        = 0.995   -- velocity damping (0–1)
Constants.PENDULUM_PUMP_STRENGTH  = 4.0     -- horizontal impulse at the tail when pumping

-- Maximum allowed bend at each joint (in degrees & radians)
Constants.SEGMENT_MAX_BEND_DEG = 5
Constants.SEGMENT_MAX_BEND_RAD = math.rad(Constants.SEGMENT_MAX_BEND_DEG)

-- Initial pivot position (roughly top-center)
Constants.PIVOT_X = 0
Constants.PIVOT_Y = 50

-- Visuals
Constants.PENDULUM_TAIL_RADIUS = 5   -- tail (last climber)
Constants.PIVOT_RADIUS         = 2   -- pivot circle radius

-- Peg defaults
Constants.PEG_DEFAULT_RADIUS = 10    -- default peg grab/draw radius

-- How many frames after a peg grab before we allow another grab
-- at 30 FPS, 10 frames = ~0.33 seconds
Constants.PEG_GRAB_COOLDOWN_FRAMES = 10
