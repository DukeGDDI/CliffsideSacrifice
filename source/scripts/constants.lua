-- scripts/constants.lua

-- Global constants table (never local, never returned)
Constants = Constants or {}

-- Playdate screen dimensions
Constants.SCREEN_WIDTH  = 400
Constants.SCREEN_HEIGHT = 240

-- Rope / pendulum tuning
Constants.PENDULUM_LENGTH_DEFAULT = 80      -- total rope length in pixels
Constants.PENDULUM_SEGMENT_COUNT  = 6       -- number of segments in the rope

Constants.PENDULUM_GRAVITY        = 0.25    -- per-frame gravity for Verlet
Constants.PENDULUM_DAMPING        = 1.0    -- velocity damping (0–1)
Constants.PENDULUM_PUMP_STRENGTH  = 4.0     -- horizontal impulse at the bob when pumping

-- Initial pivot position (roughly top-center)
Constants.PIVOT_X = Constants.SCREEN_WIDTH / 2
Constants.PIVOT_Y = 50

-- Visuals
Constants.PENDULUM_BOB_RADIUS = 5
Constants.PIVOT_RADIUS        = 2

-- Maximum allowed bend at each joint (in degrees & radians)
Constants.SEGMENT_MAX_BEND_DEG = 5
Constants.SEGMENT_MAX_BEND_RAD = math.rad(Constants.SEGMENT_MAX_BEND_DEG)

