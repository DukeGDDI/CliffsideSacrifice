-- scripts/draw.lua

local gfx = playdate.graphics

if not Constants then
    import "scripts/constants"
end
if not Entities then
    import "scripts/entities"
end
if not Camera then
    import "scripts/camera"
end

Draw = Draw or {}

-- Preload cliff images (top sky and bottom ground)
Draw.skyImage    = Draw.skyImage    or gfx.image.new("assets/images/sky.png")
Draw.groundImage = Draw.groundImage or gfx.image.new("assets/images/ground.png")


----------------------------------------------------------------
-- Helper: level/world → screen using Camera
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
        local pt = points[i]
        local sx, sy = toScreen(pt.x, pt.y)
        gfx.fillCircleAtPoint(sx, sy, 2)
    end

    ----------------------------------------------------------------
    -- Pivot (larger)
    ----------------------------------------------------------------
    local pivotX, pivotY = toScreen(points[1].x, points[1].y)
    gfx.fillCircleAtPoint(pivotX, pivotY, Constants.PIVOT_RADIUS)

    ----------------------------------------------------------------
    -- Tail / climber (largest) - last point
    ----------------------------------------------------------------
    local last = points[p.segmentCount + 1]
    local tailX, tailY = toScreen(last.x, last.y)
    gfx.fillCircleAtPoint(tailX, tailY, Constants.PENDULUM_TAIL_RADIUS)

    ----------------------------------------------------------------
    -- Loose (cut) segments
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

-- Draw the cliff top (sky) at the top of the level.
-- Top of the image sits at level Y = 0, centered on X = 0.
function Draw.drawCliffTop()
    if not Draw.skyImage or not Camera or not Camera.worldToScreen then
        return
    end

    local img = Draw.skyImage
    local w, h = img:getSize()

    -- World position for the center of the top edge of the level
    local worldX = 0
    local worldY = 0

    local cx, cy = Camera.worldToScreen(worldX, worldY)

    -- Center horizontally at cx, top edge at cy
    local screenX = cx - w / 2
    local screenY = cy

    img:draw(screenX, screenY)
end

-- Draw the cliff base (ground) at the bottom of the level.
-- Bottom of the image sits at level Y = levelHeight, centered on X = 0.
function Draw.drawCliffBase()
    if not Draw.groundImage or not Camera or not Camera.worldToScreen then
        return
    end

    local levelHeight = Entities and Entities.levelHeight or nil
    if not levelHeight then
        return
    end

    local img = Draw.groundImage
    local w, h = img:getSize()

    -- World position for the center of the bottom edge of the level
    local worldX = 0
    local worldY = levelHeight

    local cx, cy = Camera.worldToScreen(worldX, worldY)

    -- Center horizontally at cx, bottom edge at cy
    local screenX = cx - w / 2
    local screenY = cy - h

    img:draw(screenX, screenY)
end

