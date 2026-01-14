require("utils")
local IMAGES = require("images")

--number, number, ScratchEvent, CrossfadeEvent
local function drawScratchTrailEnd(startPPQ, endPPQ, scratch, lastEvent)
    local endP = (lastEvent.endPPQ - startPPQ) / (endPPQ - startPPQ)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)
    local xOffset = 0

    if scratch.position == CrossfadePos.GREEN then
        if lastEvent.position == CrossfadePos.GREEN then
            xOffset = -2*UNIT
        else
            xOffset = -UNIT
        end
    elseif scratch.position == CrossfadePos.BLUE then
        if lastEvent.position == CrossfadePos.BLUE then
            xOffset = 2*UNIT
        else
            xOffset = UNIT
        end
    end
    drawImg(IMAGES.SCRATCH_TRAIL_END, ORIGIN_X + xOffset - UNIT / 2, endY - UNIT / 2, UNIT, UNIT)
end

--number, number, ScratchEvent, CrossfadeEvent, CrossfadeEvent
local function drawScratchTrailTransition(startPPQ, endPPQ, scratch, lastEvent, cross)
    local startP = (cross.startPPQ - startPPQ) / (endPPQ - startPPQ)
    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)

    if scratch.position == CrossfadePos.GREEN then
        local image = IMAGES.SCRATCH_TRAIL_TO_RIGHT
        if (lastEvent.position == CrossfadePos.RED or lastEvent.position == CrossfadePos.BLUE) and cross.position == CrossfadePos.GREEN then
            -- center to side 
            image = IMAGES.SCRATCH_TRAIL_TO_LEFT
        end
        drawImg(image, ORIGIN_X - 2 * UNIT - UNIT / 2, startY - UNIT / 2, 2 * UNIT, UNIT)
    elseif scratch.position == CrossfadePos.BLUE then
        local image = IMAGES.SCRATCH_TRAIL_TO_LEFT
        if (lastEvent.position == CrossfadePos.GREEN or lastEvent.position == CrossfadePos.RED) and cross.position == CrossfadePos.BLUE then
            -- center to side 
            image = IMAGES.SCRATCH_TRAIL_TO_RIGHT
        end
        drawImg(image, ORIGIN_X + UNIT - UNIT / 2, startY - UNIT / 2, 2 * UNIT, UNIT)
    end
end

--number, number, ScratchEvent, CrossfadeEvent, boolean
local function drawScratchTrailFill(startPPQ, endPPQ, scratch, cross, needsAdjusting)
    local startP = math.max(0,(cross.startPPQ - startPPQ) / (endPPQ - startPPQ))
    local endP = (cross.endPPQ - startPPQ) / (endPPQ - startPPQ)

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    if needsAdjusting then
        if scratch.direction == ScratchDir.UP then
            startY = startY - 2
        elseif scratch.direction == ScratchDir.DOWN then
            startY = startY - UNIT / 4 + 2
        end
    end

    local xOffset = 0

    if scratch.position == CrossfadePos.GREEN then
        if cross.position == CrossfadePos.GREEN then
            xOffset = -2*UNIT
        else
            xOffset = -UNIT
        end
    elseif scratch.position == CrossfadePos.BLUE then
        if cross.position == CrossfadePos.BLUE then
            xOffset = 2*UNIT
        else
            xOffset = UNIT
        end
    end
    drawImg(IMAGES.SCRATCH_TRAIL_FILL, ORIGIN_X + xOffset - UNIT / 2, endY, UNIT, startY - endY)
end

--number, number, ScratchEvent, [CrossfadeEvent|CFSpikeEvent]
local function drawScratchTrail(startPPQ, endPPQ, scratch, mergedCross)
    local regions = getCrossfadeRegionsInEvent(scratch, mergedCross)

    local lastEvent = nil
    --only because the main object is transparent and the trail is fully visible underneath,
    --so we slightly alter the start so it looks better
    local needsAdjusting = true
    for _,cross in ipairs(regions) do
        drawScratchTrailFill(startPPQ, endPPQ, scratch, cross, needsAdjusting)

        if lastEvent ~= nil and lastEvent.position ~= cross.position then
            drawScratchTrailTransition(startPPQ, endPPQ, scratch, lastEvent, cross)
        end
       
        lastEvent = cross
        needsAdjusting = false
    end
    drawScratchTrailEnd(startPPQ, endPPQ, scratch, lastEvent)
end

--number, number, ScratchEvent, CrossfadePos
local function drawSingleScratch(startPPQ, endPPQ, scratch, cfPos)
    local startP = math.max(0,(scratch.startPPQ - startPPQ) / (endPPQ - startPPQ))
    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)

    if scratch.position == CrossfadePos.GREEN then
        local greenXOffset = -UNIT
        if cfPos == CrossfadePos.GREEN then
            greenXOffset = -2*UNIT
        end
        local image = nil
        if scratch.direction == ScratchDir.UP then
            image = IMAGES.SCRATCH_G_UP
        elseif scratch.direction == ScratchDir.DOWN then
            image = IMAGES.SCRATCH_G_DOWN
        elseif scratch.direction == ScratchDir.ANYDIR then
            image = IMAGES.SCRATCH_G_ANYDIR
        end
        if image ~= nil then
            drawImg(image, ORIGIN_X + greenXOffset - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        end
    elseif scratch.position == CrossfadePos.BLUE then
        local blueXOffset = UNIT
        if cfPos == CrossfadePos.BLUE then
            blueXOffset = 2*UNIT
        end
        local image = nil
        if scratch.direction == ScratchDir.UP then
            image = IMAGES.SCRATCH_B_UP
        elseif scratch.direction == ScratchDir.DOWN then
            image = IMAGES.SCRATCH_B_DOWN
        elseif scratch.direction == ScratchDir.ANYDIR then
            image = IMAGES.SCRATCH_B_ANYDIR
        end
        if image ~= nil then
            drawImg(image, ORIGIN_X + blueXOffset - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        end
    end
end

--number, number, number, [ScratchEvent], [CrossfadeEvent | CFSpikeEvent]
function drawScratches(startPPQ, endPPQ, PPQResolution, scratches, mergedCross)
    for _, scratch in ipairs(scratches) do
        local cfPos = getCrossfadePosAt(scratch.startPPQ, mergedCross)
        if scratch.endPPQ - scratch.startPPQ <= PPQResolution / 4 then
            drawSingleScratch(startPPQ, endPPQ, scratch, cfPos)
        else
            drawScratchTrail(startPPQ, endPPQ, scratch, mergedCross)
            drawSingleScratch(startPPQ, endPPQ, scratch, cfPos)
        end
    end
end
