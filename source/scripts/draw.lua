-- scripts/draw.lua

local gfx = playdate.graphics

-- Global Draw table (never local, never returned)
Draw = Draw or {}

function Draw.drawPendulum(pendulum)
    local points = pendulum.points
    if not points or #points == 0 then
        return
    end

    ----------------------------------------------------------------
    -- Rope segments (lines)
    ----------------------------------------------------------------
    for i = 1, pendulum.segmentCount do
        local a = points[i]
        local b = points[i + 1]
        gfx.drawLine(a.x, a.y, b.x, b.y)
    end

    ----------------------------------------------------------------
    -- Small circles at EVERY rope point (pivot through bob)
    ----------------------------------------------------------------
    for i = 1, pendulum.segmentCount + 1 do
        local pt = points[i]
        gfx.fillCircleAtPoint(pt.x, pt.y, 2)
    end

    ----------------------------------------------------------------
    -- Pivot (larger)
    ----------------------------------------------------------------
    local pivot = points[1]
    gfx.fillCircleAtPoint(
        pivot.x,
        pivot.y,
        Constants.PIVOT_RADIUS
    )

    ----------------------------------------------------------------
    -- Bob / climber (largest)
    ----------------------------------------------------------------
    local last = points[pendulum.segmentCount + 1]
    gfx.fillCircleAtPoint(
        last.x,
        last.y,
        Constants.PENDULUM_BOB_RADIUS
    )

    ----------------------------------------------------------------
    -- Draw loose (cut) segments as small falling dots
    ----------------------------------------------------------------
    local segments = Entities.looseSegments
    if segments and #segments > 0 then
        for i = 1, #segments do
            local seg = segments[i]
            gfx.fillCircleAtPoint(seg.x, seg.y, 2)
        end
    end
end
