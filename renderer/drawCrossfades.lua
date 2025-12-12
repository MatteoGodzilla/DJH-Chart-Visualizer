require("renderer/sizes")
require("utils")
local IMAGES = require("images")

--this DOES NOT deal with transitions
--number, number, Crossfade
local function drawLaneMiddle(startPPQ, endPPQ, crossfade)
    --REMINDER TO REMOVE TRANSITION BEFORE AND AFTER  
    local startP = math.max(0,(crossfade.startPPQ - startPPQ) / (endPPQ - startPPQ))
    local endP = (crossfade.endPPQ - startPPQ) / (endPPQ - startPPQ) 

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    drawImg(IMAGES.LANE_R_ACTIVE, ORIGIN_X -UNIT_SIZE / 2, endY + TRANSITION, UNIT_SIZE, startY - endY - 2*TRANSITION)

    --default to center position
    local greenXOff = -UNIT_SIZE
    local blueXOff = UNIT_SIZE
    local greenImg = IMAGES.LANE_G_ACTIVE
    local blueImg = IMAGES.LANE_B_ACTIVE

    --TODO: handle when effects are available

    if crossfade.position == CrossfadePos.GREEN then
        greenXOff = -2*UNIT_SIZE
        blueImg = IMAGES.LANE_B_INACTIVE
    elseif crossfade.position == CrossfadePos.BLUE then
        blueXOff = 2*UNIT_SIZE
        greenImg = IMAGES.LANE_G_INACTIVE
    end

    drawImg(greenImg, ORIGIN_X + greenXOff -UNIT_SIZE / 2, endY + TRANSITION, UNIT_SIZE, startY - endY - 2*TRANSITION)
    drawImg(blueImg, ORIGIN_X + blueXOff -UNIT_SIZE / 2, endY + TRANSITION, UNIT_SIZE, startY - endY - 2*TRANSITION)
end

--number, number, CrossfadeEvent | CFSpikeEvent, CrossfadeEvent
local function drawLaneStart(startPPQ, endPPQ, lastEvent, crossfade)
    if lastEvent == nil then
        --continue with the same lane as crossfade
        local startP = math.max(0,(crossfade.startPPQ - startPPQ) / (endPPQ - startPPQ))
        
        local startY = ORIGIN_Y + startP * (-ORIGIN_Y)

        drawImg(IMAGES.LANE_R_ACTIVE, ORIGIN_X -UNIT_SIZE / 2, startY - TRANSITION - 1, UNIT_SIZE, TRANSITION + 1)

        --default to center position
        local greenXOff = -UNIT_SIZE
        local blueXOff = UNIT_SIZE
        local greenImg = IMAGES.LANE_G_ACTIVE
        local blueImg = IMAGES.LANE_B_ACTIVE

        --TODO: handle when effects are available

        if crossfade.position == CrossfadePos.GREEN then
            greenXOff = -2*UNIT_SIZE
            blueImg = IMAGES.LANE_B_INACTIVE
        elseif crossfade.position == CrossfadePos.BLUE then
            blueXOff = 2*UNIT_SIZE
            greenImg = IMAGES.LANE_G_INACTIVE
        end

        drawImg(greenImg, ORIGIN_X + greenXOff -UNIT_SIZE / 2, startY - TRANSITION - 1, UNIT_SIZE, TRANSITION + 1)
        drawImg(blueImg, ORIGIN_X + blueXOff -UNIT_SIZE / 2, startY - TRANSITION - 1, UNIT_SIZE, TRANSITION + 1)
    elseif lastEvent.type == EventType.CROSS then
        --draw crossfade
    elseif lastEvent.type == EventType.SPIKE then
        --merge with previous spike
    end
end

--number, number, CrossfadeEvent | CFSpikeEvent, CFSpikeEvent
local function drawSpike(startPPQ, endPPQ, lastEvent, spike)

    local startP = (spike.startPPQ - startPPQ) / (endPPQ - startPPQ)
    local endP = (spike.endPPQ - startPPQ) / (endPPQ - startPPQ) 

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)
    local eventHeight = (startY - endY) - 2*TRANSITION
    local middleY = (startY + endY) / 2

    if spike.basePosition == CrossfadePos.GREEN then
        -- spike from green to red
            drawImg(IMAGES.SPIKE_G_FRONT_RIGHT_ACTIVE, ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE / 2, middleY - 1, 2 * UNIT_SIZE, eventHeight / 2)
            drawImg(IMAGES.SPIKE_G_BACK_RIGHT_ACTIVE, ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE / 2, endY + TRANSITION, 2 * UNIT_SIZE, eventHeight / 2)
    elseif spike.basePosition == CrossfadePos.RED then
        if spike.tipPosition == CrossfadePos.GREEN then
            -- spike from red to green
            -- assume both active for now
            drawImg(IMAGES.SPIKE_G_FRONT_LEFT_ACTIVE, ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE / 2, middleY - 1, 2 * UNIT_SIZE, eventHeight / 2)
            drawImg(IMAGES.SPIKE_G_BACK_LEFT_ACTIVE, ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE / 2, endY + TRANSITION, 2 * UNIT_SIZE, eventHeight / 2)
        else 
            -- spike from red to blue
            drawImg(IMAGES.SPIKE_B_FRONT_RIGHT_ACTIVE, ORIGIN_X + UNIT_SIZE - UNIT_SIZE / 2, middleY - 1, 2 * UNIT_SIZE, eventHeight / 2)
            drawImg(IMAGES.SPIKE_B_BACK_RIGHT_ACTIVE, ORIGIN_X + UNIT_SIZE - UNIT_SIZE / 2, endY + TRANSITION, 2 * UNIT_SIZE, eventHeight / 2)
        end
    elseif spike.basePosition == CrossfadePos.BLUE then
        -- spike from blue to red
            drawImg(IMAGES.SPIKE_B_FRONT_LEFT_ACTIVE, ORIGIN_X + UNIT_SIZE - UNIT_SIZE / 2, middleY - 1, 2 * UNIT_SIZE, eventHeight / 2)
            drawImg(IMAGES.SPIKE_B_BACK_LEFT_ACTIVE, ORIGIN_X + UNIT_SIZE - UNIT_SIZE / 2, endY + TRANSITION, 2 * UNIT_SIZE, eventHeight / 2)
    end

end

local function PPQComparator(a, b)
    return a.startPPQ < b.startPPQ
end

function drawCrossfades(startPPQ, endPPQ, crossfades, spikes)
    --startPPQ refers to Y position ORIGIN_Y
    --endPPQ refers to Y position 0

    local events = {}
    for _, crossfade in ipairs(crossfades) do
        table.insert(events, crossfade)
    end
    for _, spike in ipairs(spikes) do
        table.insert(events, spike)
    end

    table.sort(events, PPQComparator)

    local lastEvent = nil

    for _, event in ipairs(events) do
        glog(string.format("%d %d %d", event.type, event.startPPQ, event.endPPQ))
        if event.type == EventType.CROSS then
            drawLaneStart(startPPQ, endPPQ, lastEvent, event)
            drawLaneMiddle(startPPQ, endPPQ, event)
        elseif event.type == EventType.SPIKE then
            drawSpike(startPPQ, endPPQ, lastEvent, event)
        end
        lastEvent = event
    end
end
