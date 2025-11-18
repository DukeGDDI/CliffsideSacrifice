-- scripts/level.lua

if not Constants then
    import "scripts/constants"
end

-- Global level table (never local, never returned)
Level = Level or {}

----------------------------------------------------------------
-- RAW LEVEL DEFINITIONS (zero-indexed)
--
-- Authoring rules:
--   * Level space:
--       (0,0) = center top of the level
--       X ∈ [-levelWidth/2, +levelWidth/2]
--       Y ∈ [0, levelHeight]
--   * Pegs can be authored in two ways:
--       1) Absolute: x / y in level space
--          { id = "001", x = 0, y = 50, type = "start" }
--       2) Relative: position derived from another peg (refId)
--          { id = "002", refId = "001", segDist = 2, degOffset = 30,
--            xOffset = 0, yOffset = 10, type = "standard" }
--
--   Angle convention for relative pegs:
--     * segDist is measured in rope segment lengths
--       (segmentLength from the level or Constants.PENDULUM_SEGMENT_LENGTH)
--     * 0 degrees = directly below the reference peg (relaxed tail)
--     * Positive angles rotate toward the right
--     * Negative angles rotate toward the left
----------------------------------------------------------------

Level.levels = Level.levels or {}

-- Example baseline level (index 0)
Level.levels[0] = {
    segmentLength = 20,
    segmentCount  = 4,

    -- Author-friendly peg definitions: mix of absolute + relative
    pegs = {
        -- Start peg: absolute position, near the top center
        {
            id   = "001",
            x    = 0,
            y    = 40,
            type = "start",
        },

        -- A standard peg a couple of segment lengths down and to the right
        {
            id       = "002",
            refId    = "001",
            segDist  = 3,
            degOffset = 45,
            type     = "standard",
        },

        -- Another standard peg down and to the left of the start peg
        {
            id       = "003",
            refId    = "001",
            segDist  = 4,
            degOffset = -45,
            type     = "standard",
        },

        {
            id       = "004",
            refId    = "002",
            segDist  = 3,
            degOffset = 30,
            type     = "standard",
        },

        {
            id       = "005",
            refId    = "004",
            segDist  = 3,
            degOffset = -30,
            yOffset = 10,
            type     = "standard",
        },

        {
            id       = "006",
            refId    = "005",
            segDist  = 2,
            degOffset = -30,
            yOffset = 30,
            type     = "standard",
        },

        {
            id       = "007",
            refId    = "003",
            segDist  = 4,
            degOffset = -15,
            yOffset = 30,
            type     = "standard",
        },

        {
            id       = "008",
            refId    = "007",
            segDist  = 4,
            degOffset = 45,
            yOffset = 30,
            type     = "standard",
        },

        {
            id       = "009",
            refId    = "008",
            segDist  = 3,
            degOffset = 45,
            yOffset = 30,
            type     = "standard",
        },

        {
            id       = "010",
            refId    = "009",
            segDist  = 3,
            degOffset = 45,
            -- yOffset = 30,
            type     = "standard",
        },

        -- End peg further down from mid_01
        {
            id       = "011",
            refId    = "009",
            segDist  = 4,
            degOffset = -30,
            yOffset  = 30,
            type     = "end",
        },
    },
}

----------------------------------------------------------------
-- INTERNAL HELPER: build a concrete level config
--
-- Takes raw authoring data from Level.levels[index] and returns a
-- "built" level:
--   * segmentLength / segmentCount / width / height copied & defaulted
--   * pegs resolved to absolute x/y positions:
--       - Absolute pegs use x/y directly
--       - Relative pegs (refId) are resolved against prior pegs by id
--
-- Any peg whose refId cannot be resolved is skipped.
-- Any peg that is neither absolute nor relative is skipped.
----------------------------------------------------------------
function Level.buildLevel(index)
    local raw = Level.levels[index]
    if not raw then
        print(string.format("[Level] No raw config for index %s", tostring(index)))
        return nil
    end

    local built = {}

    ----------------------------------------------------------------
    -- Core fields
    -- segmentLength and segmentCount still come from raw or defaults.
    -- levelWidth/Height will be COMPUTED from peg positions.
    ----------------------------------------------------------------
    built.segmentLength = raw.segmentLength or Constants.PENDULUM_SEGMENT_LENGTH
    built.segmentCount  = raw.segmentCount  or Constants.PENDULUM_SEGMENT_COUNT

    -- Start with minimums; we will override after pegs are resolved.
    built.levelWidth  = Constants.SCREEN_WIDTH
    built.levelHeight = Constants.SCREEN_HEIGHT

    built.pegs = {}

    local rawPegs = raw.pegs or {}
    local byId    = {}

    ----------------------------------------------------------------
    -- Resolve pegs (absolute + relative)
    ----------------------------------------------------------------
    for i = 1, #rawPegs do
        local src = rawPegs[i]
        if src then
            local hasAbs = (src.x ~= nil and src.y ~= nil)
            local hasRef = (src.refId ~= nil)
            local peg    = nil

            if hasAbs then
                -- Absolute peg: use x/y directly
                peg = {
                    id     = src.id,
                    x      = src.x,
                    y      = src.y,
                    type   = src.type or "standard",
                    radius = src.radius or Constants.PEG_DEFAULT_RADIUS,
                }
            elseif hasRef then
                -- Relative peg: resolve against a prior peg by id
                local parent = byId[src.refId]
                if not parent then
                    print(string.format(
                        "[Level] Skipping peg id='%s': refId '%s' not found",
                        tostring(src.id),
                        tostring(src.refId)
                    ))
                else
                    local segDist = src.segDist or 0
                    local L       = segDist * built.segmentLength

                    local degOffset = src.degOffset or 0
                    local radians   = math.rad(degOffset)

                    -- 0° = straight down, positive = right, negative = left
                    local dx = L * math.sin(radians)
                    local dy = L * math.cos(radians)

                    local xOffset = src.xOffset or 0
                    local yOffset = src.yOffset or 0

                    local x = parent.x + dx + xOffset
                    local y = parent.y + dy + yOffset

                    peg = {
                        id     = src.id,
                        x      = x,
                        y      = y,
                        type   = src.type or "standard",
                        radius = src.radius or Constants.PEG_DEFAULT_RADIUS,
                    }
                end
            else
                -- Neither absolute nor relative -> skip
                print(string.format(
                    "[Level] Skipping peg id='%s': no (x,y) or refId specified",
                    tostring(src.id)
                ))
            end

            if peg then
                table.insert(built.pegs, peg)

                if peg.id ~= nil then
                    if byId[peg.id] then
                        print(string.format(
                            "[Level] Duplicate peg id '%s' in level %s; later definition overrides",
                            tostring(peg.id),
                            tostring(index)
                        ))
                    end
                    byId[peg.id] = peg
                end
            end
        end
    end

    ----------------------------------------------------------------
    -- Ensure at least one peg exists
    ----------------------------------------------------------------
    if #built.pegs == 0 then
        local defaultPeg = {
            id     = "auto_start",
            x      = Constants.PIVOT_X,
            y      = Constants.PIVOT_Y,
            type   = "start",
            radius = Constants.PEG_DEFAULT_RADIUS,
        }
        built.pegs[1] = defaultPeg
        byId[defaultPeg.id] = defaultPeg
        print(string.format(
            "[Level] Level %s had no valid pegs; created default 'auto_start' peg.",
            tostring(index)
        ))
    end

    ----------------------------------------------------------------
    -- Compute levelWidth / levelHeight from peg bounds
    --
    -- * Min width:  SCREEN_WIDTH  (400)
    -- * Min height: SCREEN_HEIGHT (240)
    --
    -- Horizontal:
    --   Use furthest left/right pegs, with a margin of 2 segments on
    --   BOTH sides. Coordinate system is centered on X=0, so we compute
    --   a symmetric half-extent around 0.
    --
    -- Vertical:
    --   Top is Y=0.
    --   Height ensures 3 segments of margin below the lowest peg.
    --   (Top margin of 2 segments is satisfied by authoring pegs with
    --    minY >= 2*segmentLength.)
    ----------------------------------------------------------------
    local minX, maxX, minY, maxY = nil, nil, nil, nil

    for i = 1, #built.pegs do
        local peg = built.pegs[i]
        local x, y = peg.x, peg.y

        if minX == nil or x < minX then minX = x end
        if maxX == nil or x > maxX then maxX = x end
        if minY == nil or y < minY then minY = y end
        if maxY == nil or y > maxY then maxY = y end
    end

    if minX ~= nil and maxX ~= nil and minY ~= nil and maxY ~= nil then
        local L = built.segmentLength

        -- Horizontal: symmetric extents around X=0
        local halfExtent      = math.max(math.abs(minX), math.abs(maxX)) + 2 * L
        local widthFromPegs   = halfExtent * 2
        if widthFromPegs < Constants.SCREEN_WIDTH then
            widthFromPegs = Constants.SCREEN_WIDTH
        end
        built.levelWidth = widthFromPegs

        -- Vertical: bottom at lowest peg + 3 segments
        local heightFromPegs = maxY + 3 * L
        if heightFromPegs < Constants.SCREEN_HEIGHT then
            heightFromPegs = Constants.SCREEN_HEIGHT
        end
        built.levelHeight = heightFromPegs
    else
        -- Fallback: keep minimums if something went very wrong
        built.levelWidth  = Constants.SCREEN_WIDTH
        built.levelHeight = Constants.SCREEN_HEIGHT
    end

    return built
end


----------------------------------------------------------------
-- PUBLIC API
----------------------------------------------------------------

-- Return the built config table for level index (or nil if not defined)
function Level.getLevel(index)
    return Level.buildLevel(index)
end
