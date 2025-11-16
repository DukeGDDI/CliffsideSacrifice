-- scripts/draw.lua

local gfx = playdate.graphics

-- Ensure globals exist if this file is loaded directly
if not Constants then
    import "scripts/constants"
end
if not Entities then
    import "scripts/entities"
end
if not Camera then
    import "scripts/camera"
end

-- Global Draw table (never local, never returned)
Draw = Draw or {}

----------------------------------------------------------------
-- Helper: world → screen with camera
----------------------------------------------------------------
local function toScreen(x, y)
    if Camera and Camera.worldToScreen then
        return Camera.worldToScreen(x, y)
    end
    return x, y
end

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

        local sx, sy = toScreen(peg.x, peg.y)
        gfx.drawCircleAtPoint(sx, sy, radius)
    end
end

----------------------------------------------------------------
-- Draw the pendulum rope + pivot + tail + loose segments
----------------------------------------------------------------
function Draw.drawPendulum(pendulum)
    local p = pendulum or Entities.pendulum
    local points = p.points
    if not points or #points == 0 then
        return
    end

    ----------------------------------------------------------------
    -- Rope segments (lines)
    ----------------------------------------------------------------
    for i = 1, p.segmentCount do
        local a = points[i]
        local b = points[i + 1]

        local x1, y1 = toScreen(a.x, a.y)
        local x2, y2 = toScreen(b.x, b.y)

        gfx.drawLine(x1, y1, x2, y2)
    end

    ----------------------------------------------------------------
    -- Small circles at EVERY rope point (pivot through tail)
    ----------------------------------------------------------------
    for i = 1, p.segmentCount + 1 do
        local pt      = points[i]
        local sx, sy  = toScreen(pt.x, pt.y)
        gfx.fillCircleAtPoint(sx, sy, 2)
    end

    ----------------------------------------------------------------
    -- Pivot (larger)
    ----------------------------------------------------------------
    local pivot      = points[1]
    local pivotX, pivotY = toScreen(pivot.x, pivot.y)
    gfx.fillCircleAtPoint(
        pivotX,
        pivotY,
        Constants.PIVOT_RADIUS
    )

    ----------------------------------------------------------------
    -- Tail / climber (largest) - last point
    ----------------------------------------------------------------
    local last       = points[p.segmentCount + 1]
    local tailX, tailY = toScreen(last.x, last.y)
    gfx.fillCircleAtPoint(
        tailX,
        tailY,
        Constants.PENDULUM_TAIL_RADIUS
    )

    ----------------------------------------------------------------
    -- Draw loose (cut) segments as small falling dots
    ----------------------------------------------------------------
    local segments = Entities.looseSegments
    if segments and #segments > 0 then
        for i = 1, #segments do
            local seg = segments[i]
            local sx, sy = toScreen(seg.x, seg.y)
            gfx.fillCircleAtPoint(sx, sy, 2)
        end
    end
end
