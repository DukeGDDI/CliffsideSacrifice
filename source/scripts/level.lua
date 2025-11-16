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
    levelWidth    = 400,
    levelHeight   = 800,
    segmentLength = 20,
    segmentCount  = 4,

    -- Author-friendly peg definitions: mix of absolute + relative
    pegs = {
        -- Start peg: absolute position, near the top center
        {
            id   = "start",
            x    = 0,
            y    = 50,
            type = "start",
        },

        -- A standard peg a couple of segment lengths down and to the right
        {
            id       = "mid_01",
            refId    = "start",
            segDist  = 3,
            degOffset = 25,
            xOffset  = 0,
            yOffset  = 10,
            type     = "standard",
        },

        -- Another standard peg down and to the left of the start peg
        {
            id       = "mid_02",
            refId    = "start",
            segDist  = 5,
            degOffset = -30,
            type     = "standard",
        },

        -- End peg further down from mid_01
        {
            id       = "end",
            refId    = "mid_01",
            segDist  = 4,
            degOffset = 5,
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

    -- Copy core fields with sensible defaults
    built.levelWidth    = raw.levelWidth    or (Constants.SCREEN_WIDTH * 2)
    built.levelHeight   = raw.levelHeight   or (Constants.SCREEN_HEIGHT * 2)
    built.segmentLength = raw.segmentLength or Constants.PENDULUM_SEGMENT_LENGTH
    built.segmentCount  = raw.segmentCount  or Constants.PENDULUM_SEGMENT_COUNT

    built.pegs = {}

    local rawPegs = raw.pegs or {}
    local byId    = {}

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

    -- If no pegs resolved at all, create a default start peg so the
    -- game has something to attach to.
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

    return built
end

----------------------------------------------------------------
-- PUBLIC API
----------------------------------------------------------------

-- Return the built config table for level index (or nil if not defined)
function Level.getLevel(index)
    return Level.buildLevel(index)
end
