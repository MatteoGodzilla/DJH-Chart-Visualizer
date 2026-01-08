local IMAGES = require("images")

--number, number, FSCrossMarkerEvent
local function drawFSCrossMarker(startPPQ, endPPQ, fsCrossfade)
    local startP = getPercentage(fsCrossfade.startPPQ, startPPQ, endPPQ)
    local endP = getPercentage(fsCrossfade.endPPQ, startPPQ, endPPQ)

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y) 
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y) + PADDING

    --local MARKER_WIDTH = 10 --to align with ingame dimentions

    if fsCrossfade.position == CrossfadePos.GREEN then
        drawImg(IMAGES.LANE_G_ACTIVE, ORIGIN_X - 2*UNIT - UNIT / 2, endY, UNIT, startY - endY)
    elseif fsCrossfade.position == CrossfadePos.BLUE then
        drawImg(IMAGES.LANE_B_ACTIVE, ORIGIN_X + 2*UNIT - UNIT / 2, endY, UNIT, startY - endY)
    end

end

--number, number, FSCrossfadeEvent
local function drawFSCrossfade(startPPQ, endPPQ, fsCrossfade)
    local startP = getPercentage(fsCrossfade.startPPQ, startPPQ, endPPQ)
    local endP = getPercentage(fsCrossfade.endPPQ, startPPQ, endPPQ)

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y) 
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y) + PADDING

    gfx.set(0,1,0,1)
    gfx.rect(ORIGIN_X - 2.5*UNIT, endY, 10, startY - endY)
    gfx.rect(ORIGIN_X - 0.5*UNIT - 10, endY, 10, startY - endY)
    gfx.set(0,0,1,1)
    gfx.rect(ORIGIN_X + 0.5*UNIT, endY, 10, startY - endY)
    gfx.rect(ORIGIN_X + 2.5*UNIT - 10, endY, 10, startY - endY)
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
