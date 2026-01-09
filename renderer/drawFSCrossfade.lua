local IMAGES = require("images")

--number, number, FSCrossMarkerEvent
local function drawFSCrossMarker(startPPQ, endPPQ, fsCrossfade)
    local startP = math.max(0,getPercentage(fsCrossfade.startPPQ, startPPQ, endPPQ))
    local endP = getPercentage(fsCrossfade.endPPQ, startPPQ, endPPQ)

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y) 
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)
    
    local THICKNESS = UNIT / 16

    if fsCrossfade.position == CrossfadePos.GREEN then
        --start
        drawImg(IMAGES.FS_CROSS_G_MARKER_START, ORIGIN_X - 2.5*UNIT, startY - THICKNESS, UNIT, THICKNESS)
        --middle
        drawImg(IMAGES.FS_CROSS_G_MARKER_MIDDLE, ORIGIN_X - 2.5*UNIT, endY + THICKNESS, UNIT, startY - endY - 2*THICKNESS + 1)
        --end
        drawImg(IMAGES.FS_CROSS_G_MARKER_END, ORIGIN_X - 2.5*UNIT, endY, UNIT, THICKNESS)
    elseif fsCrossfade.position == CrossfadePos.BLUE then
        --start
        drawImg(IMAGES.FS_CROSS_B_MARKER_START, ORIGIN_X + 1.5*UNIT, startY - THICKNESS, UNIT, THICKNESS)
        --middle
        drawImg(IMAGES.FS_CROSS_B_MARKER_MIDDLE, ORIGIN_X + 1.5*UNIT, endY + THICKNESS, UNIT, startY - endY - 2*THICKNESS + 1)
        --end
        drawImg(IMAGES.FS_CROSS_B_MARKER_END, ORIGIN_X + 1.5*UNIT, endY, UNIT, THICKNESS)
    end
end

--number, number, FSCrossfadeEvent
local function drawFSCrossfade(startPPQ, endPPQ, fsCrossfade)
    local startP = getPercentage(fsCrossfade.startPPQ, startPPQ, endPPQ)
    local endP = getPercentage(fsCrossfade.endPPQ, startPPQ, endPPQ)

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y) 
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y) + PADDING

    local THICKNESS = UNIT / 4

    --green side
    -- start
    drawImg(IMAGES.FS_CROSS_G_ZONE_START, ORIGIN_X - 2.5*UNIT, startY - THICKNESS, 2*UNIT, THICKNESS)
    -- middle
    drawImg(IMAGES.FS_CROSS_G_ZONE_MIDDLE, ORIGIN_X - 2.5*UNIT, endY + THICKNESS, 2*UNIT, startY - endY - 2*THICKNESS)
    -- end
    drawImg(IMAGES.FS_CROSS_G_ZONE_END, ORIGIN_X - 2.5*UNIT, endY, 2*UNIT, THICKNESS)

    --blue side
    -- start
    drawImg(IMAGES.FS_CROSS_B_ZONE_START, ORIGIN_X + 0.5*UNIT, startY - THICKNESS, 2*UNIT, THICKNESS)
    -- middle
    drawImg(IMAGES.FS_CROSS_B_ZONE_MIDDLE, ORIGIN_X + 0.5*UNIT, endY + THICKNESS, 2*UNIT, startY - endY - 2*THICKNESS)
    -- end
    drawImg(IMAGES.FS_CROSS_B_ZONE_END, ORIGIN_X + 0.5*UNIT, endY, 2*UNIT, THICKNESS)

end


--number, number, [FSCrossfadeEvent] 
function drawFSCrossfades(startPPQ, endPPQ, freestyle)
    for _, evt in ipairs(freestyle) do
        if evt.type == EventType.FS_CROSS then
            drawFSCrossfade(startPPQ, endPPQ, evt)
        end
    end
end

--number, number, [FSCrossfadeMarkers]
function drawFSCrossfadeMarkers(startPPQ, endPPQ, markers)
    for _, evt in ipairs(markers) do
        drawFSCrossMarker(startPPQ, endPPQ, evt)
    end
end
