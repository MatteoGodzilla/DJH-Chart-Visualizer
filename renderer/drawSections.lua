local IMAGES = require("images")

--number, number, SectionEvent
local function drawSection(startPPQ, endPPQ, section)
    local p = getPercentage(section.startPPQ, startPPQ, endPPQ)
    local y = ORIGIN_Y + p * (-ORIGIN_Y)

    oldX,oldY = gfx.x, gfx.y
    local textWidth, textHeight = gfx.measurestr(section.text)

    drawImg(IMAGES.REWIND_LEFT, ORIGIN_X - 2.5*UNIT - PADDING * 2 - MARKER_SIZE * 2, y - MARKER_SIZE, MARKER_SIZE * 2, MARKER_SIZE * 2)
    drawImg(IMAGES.REWIND_RIGHT, ORIGIN_X + 2.5*UNIT + PADDING * 2, y - MARKER_SIZE, MARKER_SIZE * 2, MARKER_SIZE * 2)

    gfx.set(0.14, 0.66, 0.92, 1)
    local textPadding = 4
    local left = ORIGIN_X + 2.5*UNIT + PADDING * 2 + MARKER_SIZE * 2
    local right = left + textWidth + textPadding * 2
    local top = y - MARKER_SIZE
    local bottom = y + MARKER_SIZE
    gfx.rect(left, top, right - left, bottom - top) 

    gfx.x = ORIGIN_X + 2.5*UNIT + PADDING * 2 + MARKER_SIZE * 2 + textPadding
    gfx.y = y - textHeight / 2 
    gfx.set(1,1,1,1)
    gfx.drawstr(section.text)

    gfx.x = oldX
    gfx.y = oldY
end

--number, number, [SectionEvent]
function drawSections(startPPQ, endPPQ, sections)
    for _, section in ipairs(sections) do
        drawSection(startPPQ, endPPQ, section)
    end
end
