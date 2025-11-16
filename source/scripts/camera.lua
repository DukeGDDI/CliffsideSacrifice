-- scripts/camera.lua
--
-- Coordinate system:
--   LEVEL SPACE: (0, 0) = CENTER TOP of the level
--   X increases to the right, decreases to the left
--   Y increases downward
--
-- Camera.x, Camera.y represent the TOP-CENTER of the viewport in level space.
--
-- Screen mapping (Playdate 400x240):
--   sx = SCREEN_WIDTH / 2 + (wx - Camera.x)
--   sy = wy - Camera.y
--
-- So if Camera.x = 0, Camera.y = 0, then:
--   world (0, 0) → screen (200, 0)

if not Constants then
    import "scripts/constants"
end

Camera = Camera or {}

----------------------------------------------------------------
-- Initialize camera for a level
----------------------------------------------------------------
-- levelWidth, levelHeight: dimensions of the level in LEVEL SPACE
--   X range: [-levelWidth/2, +levelWidth/2]
--   Y range: [0, levelHeight]
--
-- startPivotX, startPivotY: pivot position in LEVEL SPACE
--   We try to place the pivot at screenX=center, screenY=20.
----------------------------------------------------------------
function Camera.init(levelWidth, levelHeight, startPivotX, startPivotY)
    Camera.viewportWidth  = Constants.SCREEN_WIDTH
    Camera.viewportHeight = Constants.SCREEN_HEIGHT

    Camera.levelWidth  = levelWidth  or Camera.viewportWidth
    Camera.levelHeight = levelHeight or Camera.viewportHeight

    -- Lerp rate toward target
    Camera.lerpSpeed = 8.0

    -- Top-center of viewport in level space
    Camera.x = 0
    Camera.y = 0

    Camera.targetX = 0
    Camera.targetY = 0

    if startPivotX and startPivotY then
        -- We want pivot at (screen center, 20px down from top).
        -- Given world→screen:
        --   sx = 200 + (wx - Camera.x)
        --   sy = wy - Camera.y
        -- To put (wx, wy) = pivot at (200, 20):
        --   Camera.x = pivotX
        --   Camera.y = pivotY - 20
        local tx = startPivotX
        local ty = startPivotY - 20

        tx, ty = Camera.clampToBounds(tx, ty)

        Camera.x       = tx
        Camera.y       = ty
        Camera.targetX = tx
        Camera.targetY = ty
    end
end

----------------------------------------------------------------
-- Clamp camera so viewport stays within level bounds
----------------------------------------------------------------
function Camera.clampToBounds(x, y)
    local vw = Camera.viewportWidth
    local vh = Camera.viewportHeight

    local lw = Camera.levelWidth
    local lh = Camera.levelHeight

    if not lw or not lh then
        return x, y
    end

    -- Horizontal:
    -- Camera.x is top-center. Viewport covers:
    --   left  = Camera.x - vw/2
    --   right = Camera.x + vw/2
    --
    -- Level covers:
    --   left  = -lw/2
    --   right = +lw/2
    local halfViewW  = vw / 2
    local halfLevelW = lw / 2

    if lw <= vw then
        -- Level narrower than screen: just stay centered on 0
        x = 0
    else
        local minX = -halfLevelW + halfViewW
        local maxX =  halfLevelW - halfViewW
        if x < minX then x = minX end
        if x > maxX then x = maxX end
    end

    -- Vertical:
    -- Camera.y is top. Viewport covers [Camera.y, Camera.y + vh].
    -- Level covers [0, lh].
    if lh <= vh then
        -- Level shorter than screen: lock to top
        y = 0
    else
        local minY = 0
        local maxY = lh - vh
        if y < minY then y = minY end
        if y > maxY then y = maxY end
    end

    return x, y
end

----------------------------------------------------------------
-- Update target from pivot position
----------------------------------------------------------------
function Camera.setTargetFromPivot(pivotX, pivotY)
    if not pivotX or not pivotY then
        return
    end

    local tx = pivotX
    local ty = pivotY - 20

    tx, ty = Camera.clampToBounds(tx, ty)

    Camera.targetX = tx
    Camera.targetY = ty
end

----------------------------------------------------------------
-- Per-frame update
----------------------------------------------------------------
-- dt: delta time in seconds (e.g., 1/30)
-- pivotX, pivotY: current pivot position in LEVEL SPACE
----------------------------------------------------------------
function Camera.update(dt, pivotX, pivotY)
    Camera.setTargetFromPivot(pivotX, pivotY)

    local t = (Camera.lerpSpeed or 8.0) * dt
    if t > 1 then t = 1 end

    Camera.x = Camera.x + (Camera.targetX - Camera.x) * t
    Camera.y = Camera.y + (Camera.targetY - Camera.y) * t

    Camera.x, Camera.y = Camera.clampToBounds(Camera.x, Camera.y)
end

----------------------------------------------------------------
-- Coordinate transforms
----------------------------------------------------------------
-- world/level (wx, wy) → screen (sx, sy)
----------------------------------------------------------------
function Camera.worldToScreen(wx, wy)
    local sx = (Constants.SCREEN_WIDTH / 2) + (wx - Camera.x)
    local sy = wy - Camera.y
    return sx, sy
end

-- Optional: screen → world
function Camera.screenToWorld(sx, sy)
    local wx = Camera.x + (sx - Constants.SCREEN_WIDTH / 2)
    local wy = Camera.y + sy
    return wx, wy
end
