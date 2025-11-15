-- scripts/Draw.lua
import "scripts/constants"

local gfx = playdate.graphics

Draw = {}

function Draw.drawPendulum(pendulum)
    -- Rope
    gfx.drawLine(
        pendulum.pivotX,
        pendulum.pivotY,
        pendulum.bobX,
        pendulum.bobY
    )

    -- Pivot
    gfx.fillCircleAtPoint(
        pendulum.pivotX,
        pendulum.pivotY,
        Constants.PIVOT_RADIUS
    )

    -- Climber / bob
    gfx.fillCircleAtPoint(
        pendulum.bobX,
        pendulum.bobY,
        Constants.PENDULUM_BOB_RADIUS
    )
end

