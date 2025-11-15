-- scripts/entities.lua

-- Ensure Constants is loaded before we use it
if not Constants then
    import "scripts/constants"
end

-- Global entities table (never local, never returned)
Entities = Entities or {}

-- Table for rope fragments that have been cut loose
-- Each entry: { x, y, prevX, prevY }
Entities.looseSegments = Entities.looseSegments or {}

-- Pendulum / rope state
Entities.pendulum = {
    pivotX        = Constants.PIVOT_X,
    pivotY        = Constants.PIVOT_Y,
    segmentLength = Constants.PENDULUM_LENGTH_DEFAULT / Constants.PENDULUM_SEGMENT_COUNT,
    segmentCount  = Constants.PENDULUM_SEGMENT_COUNT,
    points        = {},   -- array of { x, y, prevX, prevY }
    bobX          = 0,
    bobY          = 0,
}

-- Initialize rope as a vertical chain of points under the pivot
function Entities.initPendulum()
    local p = Entities.pendulum

    p.pivotX        = Constants.PIVOT_X
    p.pivotY        = Constants.PIVOT_Y
    p.segmentCount  = Constants.PENDULUM_SEGMENT_COUNT
    p.segmentLength = Constants.PENDULUM_LENGTH_DEFAULT / p.segmentCount
    p.points        = {}

    -- Clear any previously loose segments
    Entities.looseSegments = {}

    -- Point 1: fixed pivot
    p.points[1] = {
        x     = p.pivotX,
        y     = p.pivotY,
        prevX = p.pivotX,
        prevY = p.pivotY,
    }

    -- Remaining points: hang straight down
    for i = 2, p.segmentCount + 1 do
        local y = p.pivotY + p.segmentLength * (i - 1)
        p.points[i] = {
            x     = p.pivotX,
            y     = y,
            prevX = p.pivotX,
            prevY = y,
        }
    end

    local last = p.points[#p.points]
    p.bobX = last.x
    p.bobY = last.y
end

-- Update rope physics; pumpDir = -1, 0, or 1 (left, none, right)
function Entities.updatePendulum(pumpDir)
    local p       = Entities.pendulum
    local points  = p.points
    local count   = p.segmentCount
    local gravity = Constants.PENDULUM_GRAVITY
    local damping = Constants.PENDULUM_DAMPING

    if not points or #points == 0 then
        return
    end

    ------------------------------------------------------------
    -- 1. Integrate motion for all non-pivot points (Verlet)
    ------------------------------------------------------------
    for i = 2, count + 1 do
        local pt = points[i]

        -- Current velocity from last frame (Verlet)
        local vx = (pt.x - pt.prevX) * damping
        local vy = (pt.y - pt.prevY) * damping

        -- Apply gravity
        vy = vy + gravity

        --------------------------------------------------------
        -- Pumping: horizontal impulse at the bob (last point),
        -- strongest near the bottom of the swing.
        --------------------------------------------------------
        if pumpDir ~= 0 and i == count + 1 then
            -- Vector from pivot to bob
            local dxp = pt.x - p.pivotX
            local dyp = pt.y - p.pivotY

            -- Angle from "straight down":
            -- 0   = hanging straight down
            -- ±pi = straight up above the pivot
            -- Lua's atan(y, x): atan(dxp, dyp) gives angle from +Y axis.
            local angleFromDown = math.atan(dxp, dyp)

            -- Only pump effectively within a window around the bottom,
            -- e.g. ±80° from vertical.
            local pumpWindow = math.rad(80)
            local absAngle   = math.abs(angleFromDown)

            if absAngle < pumpWindow then
                -- Linearly scale pump strength from 1 at bottom to 0 at window edge
                local factor = (pumpWindow - absAngle) / pumpWindow
                vx = vx + pumpDir * Constants.PENDULUM_PUMP_STRENGTH * factor
            end
        end

        pt.prevX = pt.x
        pt.prevY = pt.y
        pt.x = pt.x + vx
        pt.y = pt.y + vy
    end

    ------------------------------------------------------------
    -- 2. Re-anchor the pivot point (fixed)
    ------------------------------------------------------------
    local pivot = points[1]
    pivot.x     = p.pivotX
    pivot.y     = p.pivotY
    pivot.prevX = p.pivotX
    pivot.prevY = p.pivotY

    ------------------------------------------------------------
    -- 3. Satisfy distance constraints between segments
    --    + limit bend angle at each joint.
    ------------------------------------------------------------
    local segLen     = p.segmentLength
    local iterations = 5   -- stiffer rope
    local maxBend    = Constants.SEGMENT_MAX_BEND_RAD

    for _ = 1, iterations do
        --------------------------------------------------------
        -- Length constraints
        --------------------------------------------------------
        for i = 1, count do
            local a = points[i]
            local b = points[i + 1]

            local dx   = b.x - a.x
            local dy   = b.y - a.y
            local dist = math.sqrt(dx * dx + dy * dy)

            if dist > 0 then
                local diff = (dist - segLen) / dist

                -- If a is the pivot, only move b (pivot is fixed)
                if i == 1 then
                    b.x = b.x - dx * diff
                    b.y = b.y - dy * diff
                else
                    local half = 0.5
                    a.x = a.x + dx * diff * half
                    a.y = a.y + dy * diff * half
                    b.x = b.x - dx * diff * half
                    b.y = b.y - dy * diff * half
                end
            end
        end

        --------------------------------------------------------
        -- Angle constraints: limit bend at each internal joint
        --------------------------------------------------------
        for j = 2, count do
            local A = points[j - 1]  -- previous point
            local B = points[j]      -- joint
            local C = points[j + 1]  -- next point

            local abx = B.x - A.x
            local aby = B.y - A.y
            local bcx = C.x - B.x
            local bcy = C.y - B.y

            local abLen = math.sqrt(abx * abx + aby * aby)
            local bcLen = math.sqrt(bcx * bcx + bcy * bcy)

            if abLen > 0 and bcLen > 0 then
                -- Angle between AB and BC
                local dot   = abx * bcx + aby * bcy
                local denom = abLen * bcLen
                local cosT  = dot / denom

                if cosT < -1 then cosT = -1 end
                if cosT >  1 then cosT =  1 end

                local theta = math.acos(cosT)

                if theta > maxBend then
                    -- We want to rotate BC around B so angle(AB, BC) == maxBend,
                    -- preserving the side (clockwise vs counter-clockwise).
                    local cross = abx * bcy - aby * bcx
                    local sign  = 1
                    if cross < 0 then
                        sign = -1
                    end

                    local targetAngle = maxBend * sign

                    -- Unit vector along AB
                    local abUx = abx / abLen
                    local abUy = aby / abLen

                    -- Rotate AB unit vector by targetAngle to get desired BC direction
                    local ca = math.cos(targetAngle)
                    local sa = math.sin(targetAngle)

                    local bcUx = abUx * ca - abUy * sa
                    local bcUy = abUx * sa + abUy * ca

                    -- New C position: rotate around B, preserve |BC|
                    C.x = B.x + bcUx * bcLen
                    C.y = B.y + bcUy * bcLen
                end
            end
        end
    end

    ------------------------------------------------------------
    -- 4. Update bob position convenience fields
    ------------------------------------------------------------
    local last = points[count + 1]
    p.bobX = last.x
    p.bobY = last.y

    ------------------------------------------------------------
    -- 5. Update any loose (cut) segments
    ------------------------------------------------------------
    Entities.updateLooseSegments()
end





-- Update physics for segments that have been cut loose
function Entities.updateLooseSegments()
    local segments = Entities.looseSegments
    if not segments or #segments == 0 then
        return
    end

    local gravity = Constants.PENDULUM_GRAVITY
    local damping = Constants.PENDULUM_DAMPING

    local i = 1
    while i <= #segments do
        local seg = segments[i]

        -- Verlet integration for the free segment
        local vx = (seg.x - seg.prevX) * damping
        local vy = (seg.y - seg.prevY) * damping

        vy = vy + gravity

        seg.prevX = seg.x
        seg.prevY = seg.y
        seg.x = seg.x + vx
        seg.y = seg.y + vy

        -- Cull if far off-screen to avoid infinite buildup
        if seg.y > Constants.SCREEN_HEIGHT + 40
            or seg.x < -40
            or seg.x > Constants.SCREEN_WIDTH + 40 then
            table.remove(segments, i)
        else
            i = i + 1
        end
    end
end

-- Cut loose the last segment, shortening the rope.
-- The cut point becomes a free-falling segment with its current velocity.
-- Continues cutting until there is only one segment left.
function Entities.cutSegment()
    local p      = Entities.pendulum
    local points = p.points

    -- Stop if we are down to a single segment
    if p.segmentCount <= 1 then
        return
    end

    if not points or #points < 2 then
        return
    end

    -- Last point in the rope (the one we are cutting loose)
    local lastIndex = #points
    local last = points[lastIndex]

    -- Compute its current velocity from Verlet state
    local vx = last.x - last.prevX
    local vy = last.y - last.prevY

    -- Create a loose segment that continues with the same motion
    local loose = {
        x     = last.x,
        y     = last.y,
        prevX = last.x - vx,
        prevY = last.y - vy,
    }
    table.insert(Entities.looseSegments, loose)

    -- Remove the last point from the rope
    table.remove(points, lastIndex)

    -- Decrease the segment count
    p.segmentCount = p.segmentCount - 1

    -- Update bob to the new last point
    local newLast = points[#points]
    p.bobX = newLast.x
    p.bobY = newLast.y
end
