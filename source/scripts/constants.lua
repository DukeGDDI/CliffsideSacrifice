-- scripts/Constants.lua

Constants = {}

-- Playdate screen dimensions
Constants.SCREEN_WIDTH  = 400
Constants.SCREEN_HEIGHT = 240

-- Pendulum tuning
Constants.PENDULUM_LENGTH_DEFAULT = 80      -- pixels
Constants.PENDULUM_GRAVITY        = 0.15    -- tweak to taste
Constants.PENDULUM_DAMPING        = 0.002   -- small damping to keep it stable
Constants.PENDULUM_PUMP_STRENGTH  = 0.005   -- how strong each pump is

-- Initial pivot position (roughly top-center)
Constants.PIVOT_X = Constants.SCREEN_WIDTH / 2
Constants.PIVOT_Y = 50

-- Visuals
Constants.PENDULUM_BOB_RADIUS = 5
Constants.PIVOT_RADIUS        = 2

