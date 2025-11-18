-- scripts/menu_component.lua
--
-- Shared menu rendering + selection helpers.

local gfx = playdate.graphics

-- Make sure this exists before we ever index it
MenuComponent = {}

-- Helpers -----------------------------------------------------

local function isInverted()
    if not App then return false end
    if App.invertColors ~= nil then
        return App.invertColors
    end
    if App.invertColor ~= nil then
        return App.invertColor
    end
    return false
end

local function resolveColor(color)
    if not isInverted() then
        return color
    end
    if color == gfx.kColorBlack then
        return gfx.kColorWhite
    elseif color == gfx.kColorWhite then
        return gfx.kColorBlack
    end
    return color
end

local function setTextModeForColor(color)
    if color == gfx.kColorWhite then
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    else
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    end
    gfx.setColor(color)
end

-- API ---------------------------------------------------------

-- Change selection index by delta, wrapping
function MenuComponent.changeSelection(menu, delta)
    if not menu.items or #menu.items == 0 then return end

    local count = #menu.items
    local idx = menu.selectedIndex or 1
    idx = idx + delta

    if idx < 1 then
        idx = count
    elseif idx > count then
        idx = 1
    end

    menu.selectedIndex = idx
end

-- Draw the menu.
-- Positioning:
--   menu.x = horizontal CENTER of each line (if nil, center on screen)
--   menu.y = top Y of first item (if nil, vertically center)
--
-- Spacing:
--   menu.paddingX, menu.paddingY  = padding inside highlight box
--   menu.itemGap                  = vertical gap between items (default 0)
--   menu.lineHeight               = per-item height override
--
-- Colors:
--   menu.backgroundColor, textColor,
--   menu.selectedTextColor, selectedBackgroundColor
--
-- Other:
--   menu.clearBackground (default true)
function MenuComponent.draw(menu)
    local items = menu.items or {}
    local count = #items
    if count == 0 then return end

    local w, h = playdate.display.getWidth(), playdate.display.getHeight()

    -- Only background + normal text colors respect invertColors.
    -- Selected colors stay as configured so the highlight is stable.
    local bgColor       = resolveColor(menu.backgroundColor         or gfx.kColorWhite)
    local textColor     = resolveColor(menu.textColor               or gfx.kColorBlack)
    -- Selected colors respect inversion too
    local selTextColor  = resolveColor(menu.selectedTextColor       or gfx.kColorWhite)
    local selBgColor    = resolveColor(menu.selectedBackgroundColor or gfx.kColorBlack)


    local baseHeight    = menu.lineHeight          -- may be nil
    local itemGap       = menu.itemGap or 0
    local verticalOffset = menu.verticalOffset or 0
    local originX       = menu.x   -- treated as CENTER X if not nil
    local originY       = menu.y   -- top Y of first item if not nil
    local paddingX      = menu.paddingX or 4
    local paddingY      = menu.paddingY or 2
    local cornerRadius = menu.cornerRadius or 6    -- <— change radius as desired

    -- Only clear background if allowed (for screens without their own bg image)
    local clearBg = menu.clearBackground
    if clearBg == nil then clearBg = true end
    if clearBg then
        gfx.clear(bgColor)
    end

    -- Precompute metrics and total height
    local metrics = {}
    local totalHeight = 0

    for i, label in ipairs(items) do
        local textWidth, textHeight = gfx.getTextSize(label)
        local itemHeight = baseHeight or (textHeight + paddingY * 2)

        metrics[i] = {
            w = textWidth,
            h = textHeight,
            itemHeight = itemHeight,
        }

        totalHeight = totalHeight + itemHeight
    end

    totalHeight = totalHeight + itemGap * (count - 1)

    -- Compute vertical start (topY)
    local topY
    if originY ~= nil then
        topY = originY + verticalOffset
    else
        topY = math.floor((h - totalHeight) / 2) + verticalOffset
    end

    -- Draw items
    local y = topY

    for i, label in ipairs(items) do
        local m = metrics[i]
        local textWidth  = m.w
        local textHeight = m.h
        local itemHeight = m.itemHeight

        -- If originX is provided, treat it as the CENTER X for this line.
        -- Otherwise, center in the screen.
        local x
        if originX ~= nil then
            x = math.floor(originX - textWidth / 2)
        else
            x = math.floor((w - textWidth) / 2)
        end

        if i == menu.selectedIndex then
            -- selected item background
            gfx.setColor(selBgColor)
            gfx.fillRoundRect(
            x - paddingX,
            y - paddingY,
            textWidth  + paddingX * 2,
            textHeight + paddingY * 2,
            cornerRadius
        )

            setTextModeForColor(selTextColor)
            gfx.drawText(label, x, y)
        else
            setTextModeForColor(textColor)
            gfx.drawText(label, x, y)
        end

        y = y + itemHeight + itemGap
    end
end
