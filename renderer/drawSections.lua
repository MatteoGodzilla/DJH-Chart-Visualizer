
--number, number, SectionEvent
local function drawSection(startPPQ, endPPQ, section)
    local p = getPercentage(section.startPPQ, startPPQ, endPPQ)
    local y = ORIGIN_Y + p * (-ORIGIN_Y)

    oldX,oldY = gfx.x, gfx.y
    local textWidth, textHeight = gfx.measurestr(section.text)

    local triangleWidth = PADDING * 2
    local left = ORIGIN_X + 2.5*UNIT + triangleWidth + PADDING
    local right = left + textWidth 
    local top = y - gfx.texth / 2
    local bottom = top + gfx.texth

    gfx.set(1,1,1,0.2)
    gfx.rect(left, top, right - left, bottom - top) 
    gfx.triangle(left, top, left - triangleWidth, top + gfx.texth / 2, left, bottom) 

    gfx.x = left 
    gfx.y = top 
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
