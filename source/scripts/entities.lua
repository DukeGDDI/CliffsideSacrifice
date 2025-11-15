-- scripts/Entities.lua

import "scripts/constants"

Entities = {}

-- Single pendulum/climber state for now
Entities.pendulum = {
    pivotX = Constants.PIVOT_X,
    pivotY = Constants.PIVOT_Y,
    length = Constants.PENDULUM_LENGTH_DEFAULT,
    angle = -0.4,          -- radians, 0 = straight down, negative = left
    angularVelocity = 0.0,
    bobX = 0,
    bobY = 0,
}

function Entities.initPendulum()
    local p = Entities.pendulum

    p.pivotX = Constants.PIVOT_X
    p.pivotY = Constants.PIVOT_Y
    p.length = Constants.PENDULUM_LENGTH_DEFAULT
    p.angle = -0.4
    p.angularVelocity = 0.0

    -- compute initial bob position
    p.bobX = p.pivotX + p.length * math.sin(p.angle)
    p.bobY = p.pivotY + p.length * math.cos(p.angle)
end

--- Update the pendulum physics.
-- @param pumpDir -1, 0, or 1 (left, none, right)
function Entities.updatePendulum(pumpDir)
    local p = Entities.pendulum

    -- Fixed timestep for now; we can switch to dt later if needed
    local dt      = 1.0
    local g       = Constants.PENDULUM_GRAVITY
    local length  = p.length

    -- Basic pendulum equation: θ'' = -(g/L) * sin(θ)
    local angularAcceleration = -(g / length) * math.sin(p.angle)

    -- Damping
    angularAcceleration = angularAcceleration - (Constants.PENDULUM_DAMPING * p.angularVelocity)

    -- Pumping: push in direction of input
    if pumpDir ~= 0 then
        angularAcceleration = angularAcceleration + (pumpDir * Constants.PENDULUM_PUMP_STRENGTH)
    end

    -- Integrate
    p.angularVelocity = p.angularVelocity + angularAcceleration * dt
    p.angle           = p.angle + p.angularVelocity * dt

    -- Recompute bob position
    p.bobX = p.pivotX + p.length * math.sin(p.angle)
    p.bobY = p.pivotY + p.length * math.cos(p.angle)
end

