-- scripts/menu_component.lua
--
-- Shared menu rendering + selection helpers.
-- Expects a "menu" table with:
--   menu.items                   = { "Item 1", "Item 2", ... }
--   menu.selectedIndex           = 1-based index
--   menu.backgroundColor         = gfx.kColorBlack (default)
--   menu.textColor               = gfx.kColorWhite (default)
--   menu.selectedTextColor       = gfx.kColorWhite (default)
--   menu.selectedBackgroundColor = gfx.kColorBlack (default)
--   menu.lineHeight              = optional, pixels (default 20)
--   menu.verticalOffset          = optional, shift menu up/down
--
-- Colors are automatically flipped when App.invertColor == true.

local gfx = playdate.graphics

MenuComponent = MenuComponent or {}

-- Helper: flip black/white if App.invertColor is true
local function resolveColor(color)
    local invert = (App and App.invertColor) or false
    if invert then
        if color == gfx.kColorBlack then
            return gfx.kColorWhite
        elseif color == gfx.kColorWhite then
            return gfx.kColorBlack
        end
    end
    return color
end

-- Helper: choose proper text draw mode for the given color
local function setTextModeForColor(color)
    if color == gfx.kColorWhite then
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    else
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    end
end

-- Change selection index by delta, wrapping around
function MenuComponent.changeSelection(menu, delta)
    if not menu.items or #menu.items == 0 then
        return
    end

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

-- Draw the menu centered on screen
function MenuComponent.draw(menu)
    local items = menu.items or {}
    local count = #items

    local w, h = playdate.display.getWidth(), playdate.display.getHeight()

    -- DEFAULTS:
    --   background: white
    --   unselected text: black
    --   selected background: black
    --   selected text: white
    local bgColor       = resolveColor(menu.backgroundColor         or gfx.kColorWhite)
    local textColor     = resolveColor(menu.textColor               or gfx.kColorBlack)
    local selTextColor  = resolveColor(menu.selectedTextColor       or gfx.kColorWhite)
    local selBgColor    = resolveColor(menu.selectedBackgroundColor or gfx.kColorBlack)
    local lineHeight    = menu.lineHeight or 20
    local verticalOffset = menu.verticalOffset or 0

    -- Clear background
    gfx.clear(bgColor)

    if count == 0 then
        -- Nothing to draw
        return
    end

    -- Compute total menu height and top Y so we can center vertically
    local totalHeight = count * lineHeight
    local topY = math.floor((h - totalHeight) / 2) + verticalOffset

    for i, label in ipairs(items) do
        local textWidth, textHeight = gfx.getTextSize(label)
        local x = math.floor((w - textWidth) / 2)
        local y = topY + (i - 1) * lineHeight

        if i == menu.selectedIndex then
            -- Draw background box
            gfx.setColor(selBgColor)
            local paddingX = 4
            local paddingY = 2
            gfx.fillRect(
                x - paddingX,
                y - paddingY,
                textWidth + paddingX * 2,
                textHeight + paddingY * 2
            )

            -- Draw selected text
            setTextModeForColor(selTextColor)
            gfx.drawText(label, x, y)
        else
            -- Draw unselected text
            setTextModeForColor(textColor)
            gfx.drawText(label, x, y)
        end
    end
end
