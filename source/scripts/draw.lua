-- scripts/draw.lua

local gfx = playdate.graphics

-- Ensure globals exist if this file is loaded directly
if not Constants then
    import "scripts/constants"
end
if not Entities then
    import "scripts/entities"
end

-- Global Draw table (never local, never returned)
Draw = Draw or {}

----------------------------------------------------------------
-- Draw all pegs
----------------------------------------------------------------
function Draw.drawPegs(pegs)
    pegs = pegs or Entities.pegs
    if not pegs or #pegs == 0 then
        return
    end

    for i = 1, #pegs do
        local peg    = pegs[i]
        local radius = peg.radius or Constants.PEG_DEFAULT_RADIUS

        -- Simple hollow circle for a peg
        gfx.drawCircleAtPoint(peg.x, peg.y, radius)
    end
end

----------------------------------------------------------------
-- Draw the pendulum rope + pivot + tail + loose segments
----------------------------------------------------------------
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
    -- Small circles at EVERY rope point (pivot through tail)
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
    -- Tail / climber (largest) - last point
    ----------------------------------------------------------------
    local last = points[pendulum.segmentCount + 1]
    gfx.fillCircleAtPoint(
        last.x,
        last.y,
        Constants.PENDULUM_TAIL_RADIUS
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
