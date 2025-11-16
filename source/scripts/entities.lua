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
Entities.pegGrabCooldownFrames = Entities.pegGrabCooldownFrames or 0

-- Pegs: configured via level, owned at runtime by Entities
-- Each peg: { x, y, radius, type = "standard" }
Entities.pegs = Entities.pegs or {}

-- Level bounds (default to screen size if level doesn't override)
Entities.levelWidth  = Entities.levelWidth  or Constants.SCREEN_WIDTH
Entities.levelHeight = Entities.levelHeight or Constants.SCREEN_HEIGHT

-- Pendulum / rope state
Entities.pendulum = {
    pivotX        = Constants.PIVOT_X,
    pivotY        = Constants.PIVOT_Y,
    segmentLength = Constants.PENDULUM_SEGMENT_LENGTH,
    segmentCount  = Constants.PENDULUM_SEGMENT_COUNT,
    points        = {},   -- array of { x, y, prevX, prevY }
    tailX         = 0,    -- convenience: last segment position
    tailY         = 0,
    attached      = true, -- true = swinging around a pivot, false = free-flying rope
}

----------------------------------------------------------------
-- Peg API
----------------------------------------------------------------

-- Configure pegs for the current level.
-- pegs: array of { x, y, radius?, type? }
function Entities.setPegs(pegs)
    Entities.pegs = {}

    if not pegs then
        return
    end

    for i = 1, #pegs do
        local src = pegs[i]
        Entities.pegs[i] = {
            x      = src.x,
            y      = src.y,
            radius = src.radius or Constants.PEG_DEFAULT_RADIUS,
            type   = src.type or "standard",
        }
    end
end

----------------------------------------------------------------
-- Pendulum / rope setup
----------------------------------------------------------------

-- Initialize rope as a vertical chain of points under a pivot.
-- Pivot and rope configuration are taken from Level.current if available,
-- otherwise fall back to Constants defaults.
function Entities.initPendulum()
    local p = Entities.pendulum

    -- Level config (if any)
    local cfg = Level.getLevel(Game.currentLevelIndex) or nil
    local levelPegs = (cfg and cfg.pegs) or Entities.pegs

    -- If no pegs defined, create a simple default start peg
    if not levelPegs or #levelPegs == 0 then
        levelPegs = {
            {
                x      = Constants.PIVOT_X,
                y      = Constants.PIVOT_Y,
                radius = Constants.PEG_DEFAULT_RADIUS,
                type   = "start",
            },
        }
        Entities.pegs = levelPegs
    end

    local startPeg = levelPegs[1]
    local pivotX   = startPeg.x
    local pivotY   = startPeg.y

    -- NEW: use segmentLength + segmentCount
    local segmentCount  = (cfg and cfg.segmentCount)  or Constants.PENDULUM_SEGMENT_COUNT
    local segmentLength = (cfg and cfg.segmentLength) or Constants.PENDULUM_SEGMENT_LENGTH

    -- Level bounds from config (if present)
    Entities.levelWidth  = (cfg and cfg.levelWidth)  or Constants.SCREEN_WIDTH
    Entities.levelHeight = (cfg and cfg.levelHeight) or Constants.SCREEN_HEIGHT

    p.pivotX        = pivotX
    p.pivotY        = pivotY
    p.segmentCount  = segmentCount
    p.segmentLength = segmentLength
    p.points        = {}
    p.attached      = true

    -- Reset helper state
    Entities.looseSegments         = {}
    Entities.pegGrabCooldownFrames = 0

    -- Point 1: pivot
    p.points[1] = {
        x     = pivotX,
        y     = pivotY,
        prevX = pivotX,
        prevY = pivotY,
    }

    -- Hang rope vertically from the pivot, using segmentLength
    for i = 2, p.segmentCount + 1 do
        local y = pivotY + p.segmentLength * (i - 1)
        p.points[i] = {
            x     = pivotX,
            y     = y,
            prevX = pivotX,
            prevY = y,
        }
    end

    local tail = p.points[#p.points]
    p.tailX = tail.x
    p.tailY = tail.y
end





----------------------------------------------------------------
-- Level reset / fail handling
----------------------------------------------------------------

-- Reset the level state.
-- If a Level module exists, go through Level.apply() so pivot, rope, and pegs
-- are all consistent. Otherwise, just re-init the pendulum.
function Entities.resetLevel()
    -- Prefer going through Game if it exists (future-proof for multi-level support)
    if Game and Game.reloadLevel then
        Game.reloadLevel()
        return
    end

    -- Last resort: just rebuild the pendulum with whatever config exists
    Entities.initPendulum()
end




----------------------------------------------------------------
-- Peg grabbing helpers
----------------------------------------------------------------

-- Check if the tail collides with any peg; if so, grab the closest.
-- This is active in BOTH attached and released modes.
function Entities.checkPegGrab()
    -- 🔹 If we're still in cooldown, skip peg checks
    if Entities.pegGrabCooldownFrames and Entities.pegGrabCooldownFrames > 0 then
        return
    end

    local p      = Entities.pendulum
    local points = p.points
    local count  = p.segmentCount
    local pegs   = Entities.pegs

    if not pegs or #pegs == 0 or not points or #points == 0 then
        return
    end

    local tail = points[count + 1]
    local tx   = tail.x
    local ty   = tail.y

    local closestIndex = nil
    local closestDist2 = nil

    for i = 1, #pegs do
        local peg    = pegs[i]
        local radius = peg.radius or Constants.PEG_DEFAULT_RADIUS

        local dx    = tx - peg.x
        local dy    = ty - peg.y
        local dist2 = dx * dx + dy * dy

        if dist2 <= radius * radius then
            if not closestDist2 or dist2 < closestDist2 then
                closestDist2 = dist2
                closestIndex = i
            end
        end
    end

    if closestIndex then
        Entities.grabPeg(closestIndex)
    end
end

-- Grab the peg at index pegIndex:
--  - The rope's pivot jumps to the peg.
--  - The rope is reindexed so the previous tail's chain trails behind.
--  - Rope length and segment count are preserved.
--  - The rope becomes attached again.
function Entities.grabPeg(pegIndex)
    local peg = Entities.pegs[pegIndex]
    if not peg then
        return
    end

    local p         = Entities.pendulum
    local oldPoints = p.points
    local count     = p.segmentCount

    if not oldPoints or #oldPoints < 2 then
        return
    end

    local newPoints = {}

    -- New pivot at the peg position
    newPoints[1] = {
        x     = peg.x,
        y     = peg.y,
        prevX = peg.x,
        prevY = peg.y,
    }

    -- Rebuild the rest of the rope as a reversed chain behind the new pivot.
    -- We ignore oldPoints[count+1] (tail) and reverse 1..count behind the new pivot.
    --
    -- newPoints[2]      corresponds to oldPoints[count]
    -- newPoints[count+1] corresponds to oldPoints[1]
    for k = 1, count do
        local srcIndex = count + 1 - k
        local src      = oldPoints[srcIndex]

        newPoints[k + 1] = {
            x     = src.x,
            y     = src.y,
            prevX = src.x,
            prevY = src.y,
        }
    end

    p.points   = newPoints
    p.pivotX   = peg.x
    p.pivotY   = peg.y
    p.attached = true

    -- Update tail convenience fields
    local tail = newPoints[count + 1]
    p.tailX = tail.x
    p.tailY = tail.y

    -- 🔹 Start cooldown so we don't immediately grab another peg
    Entities.pegGrabCooldownFrames = Constants.PEG_GRAB_COOLDOWN_FRAMES

    -- Next updatePendulum call will naturally settle the rope.
end

----------------------------------------------------------------
-- Release / attach API
----------------------------------------------------------------

-- Release the rope from its current pivot so it flies freely.
function Entities.releasePivot()
    local p = Entities.pendulum
    if not p.attached then
        return
    end
    p.attached = false
end

----------------------------------------------------------------
-- Pendulum / rope update
----------------------------------------------------------------

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

    -- 1. Integrate motion (Verlet + gravity + pumping)
    Entities._integratePendulumPoints(p, points, count, pumpDir, gravity, damping)

    -- 2. Re-anchor pivot if attached
    Entities._reanchorPivotIfAttached(p, points)

    -- 3. Satisfy distance constraints + limit bend angles
    Entities._solvePendulumConstraints(p, points, count)

    -- 4. Update tail convenience fields
    Entities._updatePendulumTail(p, points, count)

    -- 5. Peg cooldown + grab checks
    Entities._updatePegCooldownAndCheckGrab()

    -- 6. Fail condition (may reset level)
    if Entities._checkPendulumFailCondition(p) then
        return
    end

    -- 7. Update any loose (cut) segments
    Entities.updateLooseSegments()
end

----------------------------------------------------------------
-- Helper: integrate points (Verlet + gravity + pumping)
----------------------------------------------------------------
function Entities._integratePendulumPoints(p, points, count, pumpDir, gravity, damping)
    ------------------------------------------------------------
    -- Integrate motion for all points except the pivot when attached
    -- (When released, ALL points are integrated freely.)
    ------------------------------------------------------------
    local startIndex = 2
    if not p.attached then
        -- When released, point 1 is no longer anchored; integrate it too.
        startIndex = 1
    end

    for i = startIndex, count + 1 do
        local pt = points[i]

        -- Current velocity from last frame (Verlet)
        local vx = (pt.x - pt.prevX) * damping
        local vy = (pt.y - pt.prevY) * damping

        -- Apply gravity
        vy = vy + gravity

        --------------------------------------------------------
        -- Pumping: horizontal impulse at the tail (last point),
        -- strongest near the bottom of the swing.
        -- Only meaningful when attached to a pivot.
        --------------------------------------------------------
        if p.attached and pumpDir ~= 0 and i == count + 1 then
            -- Vector from pivot to tail
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
end

----------------------------------------------------------------
-- Helper: re-anchor pivot when attached
----------------------------------------------------------------
function Entities._reanchorPivotIfAttached(p, points)
    if p.attached then
        local pivot = points[1]
        pivot.x     = p.pivotX
        pivot.y     = p.pivotY
        pivot.prevX = p.pivotX
        pivot.prevY = p.pivotY
    end
end

----------------------------------------------------------------
-- Helper: constraints (segment length + max bend)
----------------------------------------------------------------
function Entities._solvePendulumConstraints(p, points, count)
    ------------------------------------------------------------
    -- Satisfy distance constraints between segments
    -- + limit bend angle at each joint.
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

                if p.attached and i == 1 then
                    -- Attached: pivot is fixed; only move the second point.
                    b.x = b.x - dx * diff
                    b.y = b.y - dy * diff
                else
                    -- Otherwise, move both endpoints halfway.
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
end

----------------------------------------------------------------
-- Helper: update tail convenience fields
----------------------------------------------------------------
function Entities._updatePendulumTail(p, points, count)
    local tail = points[count + 1]
    p.tailX = tail.x
    p.tailY = tail.y
end

----------------------------------------------------------------
-- Helper: cooldown + peg grabbing
----------------------------------------------------------------
function Entities._updatePegCooldownAndCheckGrab()
    if Entities.pegGrabCooldownFrames and Entities.pegGrabCooldownFrames > 0 then
        Entities.pegGrabCooldownFrames = Entities.pegGrabCooldownFrames - 1
        if Entities.pegGrabCooldownFrames < 0 then
            Entities.pegGrabCooldownFrames = 0
        end
    end

    Entities.checkPegGrab()
end

----------------------------------------------------------------
-- Helper: fail condition (returns true if level reset)
----------------------------------------------------------------
function Entities._checkPendulumFailCondition(p)
    ------------------------------------------------------------
    -- Fail condition:
    --   When the rope is RELEASED and the tail leaves the
    --   CAMERA'S VIEWPORT (with some margin), reset the level.
    --
    -- If no Camera is available, fall back to a simple
    -- level-bounds check in level space.
    ------------------------------------------------------------
    if not p.attached then
        local tx, ty = p.tailX, p.tailY
        local margin = 40

        local outOfView = false

        -- Prefer camera-based viewport check
        if Camera and Camera.x and Camera.y then
            -- Camera.x, Camera.y = TOP-CENTER of viewport in LEVEL SPACE
            -- Viewport in level space:
            --   left   = Camera.x - SCREEN_WIDTH/2
            --   right  = Camera.x + SCREEN_WIDTH/2
            --   top    = Camera.y
            --   bottom = Camera.y + SCREEN_HEIGHT
            local halfW = Constants.SCREEN_WIDTH / 2

            local viewLeft   = Camera.x - halfW
            local viewRight  = Camera.x + halfW
            local viewTop    = Camera.y
            local viewBottom = Camera.y + Constants.SCREEN_HEIGHT

            if ty > viewBottom + margin
               or ty < viewTop    - margin
               or tx < viewLeft   - margin
               or tx > viewRight  + margin then
                outOfView = true
            end
        else
            ----------------------------------------------------
            -- Fallback: use level bounds in LEVEL SPACE.
            -- Here we assume:
            --   X ∈ [-w/2, +w/2]
            --   Y ∈ [0, h]
            ----------------------------------------------------
            local w = Entities.levelWidth  or Constants.SCREEN_WIDTH
            local h = Entities.levelHeight or Constants.SCREEN_HEIGHT
            local halfW = w / 2

            local levelLeft   = -halfW
            local levelRight  =  halfW
            local levelTop    = 0
            local levelBottom = h

            if ty > levelBottom + margin
               or ty < levelTop    - margin
               or tx < levelLeft   - margin
               or tx > levelRight  + margin then
                outOfView = true
            end
        end

        if outOfView then
            Entities.resetLevel()
            return true
        end
    end

    return false
end




----------------------------------------------------------------
-- Update physics for segments that have been cut loose
----------------------------------------------------------------
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

----------------------------------------------------------------
-- Cut loose the last segment, shortening the rope.
-- The cut point becomes a free-falling segment with its current velocity.
-- Continues cutting until there is only one segment left.
----------------------------------------------------------------
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
    local last      = points[lastIndex]

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

    -- Update tail to the new last point
    local newLast = points[#points]
    p.tailX = newLast.x
    p.tailY = newLast.y
end

