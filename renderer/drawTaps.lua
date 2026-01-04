local IMAGES = require("images")

local function drawTapTrailEnd(startPPQ, endPPQ, tap, lastEvent)
    local endP = (lastEvent.endPPQ - startPPQ) / (endPPQ - startPPQ)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    if tap.position == CrossfadePos.GREEN then
        local xOffset = -UNIT
        if lastEvent.position == CrossfadePos.GREEN then
            xOffset = -2*UNIT
        end
        drawImg(IMAGES.TAP_TRAIL_G_END, ORIGIN_X + xOffset - UNIT / 2, endY - UNIT / 2, UNIT, UNIT)
    elseif tap.position == CrossfadePos.RED then
        drawImg(IMAGES.TAP_TRAIL_R_END, ORIGIN_X - UNIT / 2, endY - UNIT / 2, UNIT, UNIT)
    elseif tap.position == CrossfadePos.BLUE then
        local xOffset = UNIT
        if lastEvent.position == CrossfadePos.BLUE then
            xOffset = 2*UNIT
        end
        drawImg(IMAGES.TAP_TRAIL_B_END, ORIGIN_X + xOffset - UNIT / 2, endY - UNIT / 2, UNIT, UNIT)
    end
end

local function drawTapTrailTransition(startPPQ, endPPQ, tap, lastEvent, cross)
    local startP = (cross.startPPQ - startPPQ) / (endPPQ - startPPQ)
    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)

    if tap.position == CrossfadePos.GREEN then
        local image = IMAGES.TAP_TRAIL_G_TO_RIGHT
        if (lastEvent.position == CrossfadePos.RED or lastEvent.position == CrossfadePos.BLUE) and cross.position == CrossfadePos.GREEN then
            -- center to side 
            image = IMAGES.TAP_TRAIL_G_TO_LEFT
        end
        drawImg(image, ORIGIN_X - 2 * UNIT - UNIT / 2, startY - UNIT / 2, 2 * UNIT, UNIT)
    elseif tap.position == CrossfadePos.BLUE then
        local image = IMAGES.TAP_TRAIL_B_TO_LEFT
        if (lastEvent.position == CrossfadePos.GREEN or lastEvent.position == CrossfadePos.RED) and cross.position == CrossfadePos.BLUE then
            -- center to side 
            image = IMAGES.TAP_TRAIL_B_TO_RIGHT
        end
        drawImg(image, ORIGIN_X + UNIT - UNIT / 2, startY - UNIT / 2, 2 * UNIT, UNIT)
    end
end

--number, number, TapEvent, CrossfadeEvent
local function drawTapTrailFill(startPPQ, endPPQ, tap, cross)
    local startP = math.max(0,(cross.startPPQ - startPPQ) / (endPPQ - startPPQ))
    local endP = (cross.endPPQ - startPPQ) / (endPPQ - startPPQ)

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    if tap.position == CrossfadePos.GREEN then
        local xOffset = -UNIT
        if cross.position == CrossfadePos.GREEN then
            xOffset = -2*UNIT
        end
        drawImg(IMAGES.TAP_TRAIL_G_FILL, ORIGIN_X + xOffset - UNIT / 2, endY, UNIT, startY - endY)
    elseif tap.position == CrossfadePos.RED then
        drawImg(IMAGES.TAP_TRAIL_R_FILL, ORIGIN_X - UNIT / 2, endY, UNIT, startY - endY)
    elseif tap.position == CrossfadePos.BLUE then
        local xOffset = UNIT
        if cross.position == CrossfadePos.BLUE then
            xOffset = 2*UNIT
        end
        drawImg(IMAGES.TAP_TRAIL_B_FILL, ORIGIN_X + xOffset - UNIT / 2, endY, UNIT, startY - endY)
    end
end

--number, number, TapEvent, [CrossfadeEvent|CFSpikeEvent]
local function drawTapTrail(startPPQ, endPPQ, tap, mergedCross)
    local regions = getCrossfadeRegionsInEvent(tap, mergedCross)

    local lastEvent = nil
    for _,cross in ipairs(regions) do
        drawTapTrailFill(startPPQ, endPPQ, tap, cross)

        if lastEvent ~= nil and lastEvent.position ~= cross.position then
            drawTapTrailTransition(startPPQ, endPPQ, tap, lastEvent, cross)
        end
       
        lastEvent = cross
    end
    drawTapTrailEnd(startPPQ, endPPQ, tap, lastEvent)
end

--number, number, TapEvent, CrossfadePos
local function drawSingleTap(startPPQ, endPPQ, tap, cfPos)
    local startP = math.max(0,(tap.startPPQ - startPPQ) / (endPPQ - startPPQ))
    --TODO: figure out a better solution for held taps
    if startP < 0 then
        return
    end
    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)

    if tap.position == CrossfadePos.GREEN then
        local greenXOff = -UNIT
        if cfPos == CrossfadePos.GREEN then
            greenXOff = -2*UNIT
        end
        drawImg(IMAGES.TAP_G_L0, ORIGIN_X + greenXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_G_L1, ORIGIN_X + greenXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_G_L2, ORIGIN_X + greenXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_G_L3, ORIGIN_X + greenXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
    elseif tap.position == CrossfadePos.RED then
        drawImg(IMAGES.TAP_R_L0, ORIGIN_X - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_R_L1, ORIGIN_X - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_R_L2, ORIGIN_X - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_R_L3, ORIGIN_X - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
    elseif tap.position == CrossfadePos.BLUE then
        local blueXOff = UNIT
        if cfPos == CrossfadePos.BLUE then
            blueXOff = 2*UNIT
        end
        drawImg(IMAGES.TAP_B_L0, ORIGIN_X + blueXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_B_L1, ORIGIN_X + blueXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_B_L2, ORIGIN_X + blueXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_B_L3, ORIGIN_X + blueXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
    end
end

--number, number, number, [TapEvent], [CrossfadeEvent | CFSpikeEvent]
function drawTaps(startPPQ, endPPQ, PPQResolution, taps, mergedCross)
    for _, tap in ipairs(taps) do
        local startTime = math.max(tap.startPPQ, startPPQ)
        local cfPos = getCrossfadePosAt(startTime, mergedCross)
        if tap.endPPQ - tap.startPPQ <= PPQResolution / 4 then
            drawSingleTap(startPPQ, endPPQ, tap, cfPos)
        else
            drawTapTrail(startPPQ, endPPQ, tap, mergedCross)
            drawSingleTap(startPPQ, endPPQ, tap, cfPos)
        end
    end
end
