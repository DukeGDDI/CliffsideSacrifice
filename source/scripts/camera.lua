-- scripts/camera.lua
--
-- Camera is a global singleton.
-- Coordinates are in WORLD space (same as Entities / Level).
--
-- For now we keep the existing top-left origin convention:
--   (0,0) = top-left of the level
--
-- Camera.x, Camera.y represent the TOP-LEFT of the viewport in world coords.
-- Playdate screen is 400x240, so:
--   visible X range = [Camera.x, Camera.x + 400]
--   visible Y range = [Camera.y, Camera.y + 240]

if not Constants then
    import "scripts/constants"
end

Camera = Camera or {}

-- Initialize or reset the camera for a given level.
-- levelWidth / levelHeight: world dimensions of the level.
-- startPivotX / startPivotY: initial pivot position in world coordinates.
function Camera.init(levelWidth, levelHeight, startPivotX, startPivotY)
    Camera.viewportWidth  = Constants.SCREEN_WIDTH
    Camera.viewportHeight = Constants.SCREEN_HEIGHT

    Camera.levelWidth  = levelWidth or Camera.viewportWidth
    Camera.levelHeight = levelHeight or Camera.viewportHeight

    Camera.lerpSpeed = 8.0  -- how quickly we follow the target

    -- Top-left of viewport in world space
    Camera.x = 0
    Camera.y = 0

    Camera.targetX = 0
    Camera.targetY = 0

    if startPivotX and startPivotY then
        -- We want pivot at (screenX=200, screenY=20)
        -- With top-left camera, that means:
        --   Camera.x = pivotX - 200
        --   Camera.y = pivotY - 20
        local tx = startPivotX - (Camera.viewportWidth / 2)
        local ty = startPivotY - 20
        tx, ty = Camera.clampToBounds(tx, ty)
        Camera.x       = tx
        Camera.y       = ty
        Camera.targetX = tx
        Camera.targetY = ty
    end
end

-- Clamp the camera so that the viewport stays within the level bounds.
-- Level is assumed to span horizontally from 0 to levelWidth,
-- and vertically from 0 to levelHeight.
function Camera.clampToBounds(x, y)
    local vw = Camera.viewportWidth
    local vh = Camera.viewportHeight

    local lw = Camera.levelWidth  or vw
    local lh = Camera.levelHeight or vh

    -- If the level is narrower than the view, lock x = 0
    if lw <= vw then
        x = 0
    else
        local minX = 0
        local maxX = lw - vw
        if x < minX then x = minX end
        if x > maxX then x = maxX end
    end

    -- If the level is shorter than the view, lock y = 0
    if lh <= vh then
        y = 0
    else
        local minY = 0
        local maxY = lh - vh
        if y < minY then y = minY end
        if y > maxY then y = maxY end
    end

    return x, y
end

-- Set the camera's target based on the pivot position in world space.
-- Desired on-screen pivot position:
--   screenX = 200 (center)
--   screenY = 20 (slightly down from top)
function Camera.setTargetFromPivot(pivotX, pivotY)
    if not pivotX or not pivotY then
        return
    end

    local vw = Camera.viewportWidth or 400

    -- To put pivot at screenX=vw/2, screenY=20:
    local tx = pivotX - (vw / 2)
    local ty = pivotY - 20

    tx, ty = Camera.clampToBounds(tx, ty)

    Camera.targetX = tx
    Camera.targetY = ty
end

-- dt is the frame delta in seconds (e.g., 1/30).
-- pivotX, pivotY are the current pivot coordinates in world space.
function Camera.update(dt, pivotX, pivotY)
    -- Always update target from pivot
    Camera.setTargetFromPivot(pivotX, pivotY)

    local t = (Camera.lerpSpeed or 8.0) * dt
    if t > 1 then t = 1 end

    Camera.x = Camera.x + (Camera.targetX - Camera.x) * t
    Camera.y = Camera.y + (Camera.targetY - Camera.y) * t

    -- Just in case numerical drift pushes us out of bounds
    Camera.x, Camera.y = Camera.clampToBounds(Camera.x, Camera.y)
end

-- Convert world coordinates (wx, wy) to screen coordinates (sx, sy).
-- With a top-left camera:
--   sx = wx - Camera.x
--   sy = wy - Camera.y
function Camera.worldToScreen(wx, wy)
    local sx = wx - Camera.x
    local sy = wy - Camera.y
    return sx, sy
end

-- Optional helper: convert screen→world if needed.
function Camera.screenToWorld(sx, sy)
    local wx = Camera.x + sx
    local wy = Camera.y + sy
    return wx, wy
end
