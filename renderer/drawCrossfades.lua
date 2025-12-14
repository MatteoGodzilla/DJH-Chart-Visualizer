require("renderer/sizes")
require("utils")
local IMAGES = require("images")

-- CrossfadePos, CrossfadePos, number
local function drawCrossfadeGeneral(before, after, Y)
    --the crossfade is drawn as a rectangle where center lies at height Y and total height is 2*TRANSITION
    --In all cases the center lane has the same exact image: LANE_R_ACTIVE

    gfx.set(0,0,1)
    gfx.rect(DEBUG_ORIGIN_X + 10, Y - TRANSITION, 10, 2*TRANSITION)
    drawImg(IMAGES.LANE_R_ACTIVE, ORIGIN_X - UNIT_SIZE/2, Y - TRANSITION, UNIT_SIZE, 2 * TRANSITION)

    --TODO: handle effects
    if before == CrossfadePos.GREEN then
        if after == CrossfadePos.RED then
            --green to red
            drawImg(IMAGES.CROSS_G_LEFT_FRONT_ACTIVE, ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
            drawImg(IMAGES.CROSS_G_RIGHT_BACK_ACTIVE, ORIGIN_X - UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
            --blue lane inactive -> active
            --[[
            gfx.set(0,0,1)
            gfx.rect(ORIGIN_X + UNIT_SIZE - UNIT_SIZE/2, Y - TRANSITION, UNIT_SIZE, 2 * TRANSITION)
            ]]--
        elseif after == CrossfadePos.BLUE then
            --green to red crossfade
            drawImg(IMAGES.CROSS_G_LEFT_FRONT_ACTIVE, ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
            drawImg(IMAGES.CROSS_G_RIGHT_BACK_INACTIVE, ORIGIN_X - UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
            --red to blue crossfade 
            drawImg(IMAGES.CROSS_B_LEFT_FRONT_INACTIVE, ORIGIN_X + UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
            drawImg(IMAGES.CROSS_B_RIGHT_BACK_ACTIVE, ORIGIN_X + 2 * UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
        end
    elseif before == CrossfadePos.RED then
        if after == CrossfadePos.GREEN then
            --red to green crossfade
            drawImg(IMAGES.CROSS_G_LEFT_BACK_ACTIVE, ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
            drawImg(IMAGES.CROSS_G_RIGHT_FRONT_ACTIVE, ORIGIN_X - UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
            --blue lane active -> inactive
            --[[
            gfx.set(0,0,1)
            gfx.rect(ORIGIN_X + UNIT_SIZE - UNIT_SIZE/2, Y - TRANSITION, UNIT_SIZE, 2 * TRANSITION)
            ]]--
        elseif after == CrossfadePos.BLUE then
            --green lane active -> inactive
            --[[
            gfx.set(0,1,0)
            gfx.rect(ORIGIN_X - UNIT_SIZE - UNIT_SIZE/2, Y - TRANSITION, UNIT_SIZE, 2 * TRANSITION)
            ]]--
            --red to blue crossfade 
            drawImg(IMAGES.CROSS_B_LEFT_FRONT_ACTIVE, ORIGIN_X + UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
            drawImg(IMAGES.CROSS_B_RIGHT_BACK_ACTIVE, ORIGIN_X + 2 * UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
        end
    elseif before == CrossfadePos.BLUE then
        if after == CrossfadePos.GREEN then
            --red to green crossfade
            drawImg(IMAGES.CROSS_G_LEFT_BACK_ACTIVE, ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
            drawImg(IMAGES.CROSS_G_RIGHT_FRONT_INACTIVE, ORIGIN_X - UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
            --blue to red crossfade 
            drawImg(IMAGES.CROSS_B_LEFT_BACK_INACTIVE, ORIGIN_X + UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
            drawImg(IMAGES.CROSS_B_RIGHT_FRONT_ACTIVE, ORIGIN_X + 2 * UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
        elseif after == CrossfadePos.RED then
            --green lane inactive -> active
            --[[
            gfx.set(0,1,0)
            gfx.rect(ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE/2, Y - TRANSITION, 2 * UNIT_SIZE, 2 * TRANSITION)
            ]]--
            --blue to red crossfade 
            drawImg(IMAGES.CROSS_B_LEFT_BACK_ACTIVE, ORIGIN_X + UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
            drawImg(IMAGES.CROSS_B_RIGHT_FRONT_ACTIVE, ORIGIN_X + 2 * UNIT_SIZE - UNIT_SIZE / 2, Y - TRANSITION, UNIT_SIZE, 2*TRANSITION)
        end
    end
end

-- CrossfadePos, number, number
local function drawLaneGeneral(position, startY, endY)
    drawImg(IMAGES.LANE_R_ACTIVE, ORIGIN_X - UNIT_SIZE / 2, endY, UNIT_SIZE, startY - endY)
    --default to center position
    local greenXOff = -UNIT_SIZE
    local blueXOff = UNIT_SIZE
    local greenImg = IMAGES.LANE_G_ACTIVE
    local blueImg = IMAGES.LANE_B_ACTIVE

    --TODO: handle when effects are available

    if position == CrossfadePos.GREEN then
        greenXOff = -2*UNIT_SIZE
        blueImg = IMAGES.LANE_B_INACTIVE
    elseif position == CrossfadePos.BLUE then
        blueXOff = 2*UNIT_SIZE
        greenImg = IMAGES.LANE_G_INACTIVE
    end
    drawImg(greenImg, ORIGIN_X + greenXOff -UNIT_SIZE / 2, endY, UNIT_SIZE, startY - endY)
    drawImg(blueImg, ORIGIN_X + blueXOff -UNIT_SIZE / 2, endY, UNIT_SIZE, startY - endY)
end

--number, number, CrossfadeEvent | CFSpikeEvent | nil, CrossfadeEvent
local function drawCrossfadeEvent(startPPQ, endPPQ, lastEvent, crossfade)
    local startP = math.max(0,(crossfade.startPPQ - startPPQ) / (endPPQ - startPPQ))
    local endP = (crossfade.endPPQ - startPPQ) / (endPPQ - startPPQ) 

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)
    endY = endY + TRANSITION -- always allocate space for the next event

    if lastEvent ~= nil and lastEvent.type == EventType.CROSS then
        drawCrossfadeGeneral(lastEvent.position, crossfade.position, startY)
        --draw transition image aka crossfade itself 
        startY = startY - TRANSITION
    end

    drawLaneGeneral(crossfade.position, startY, endY)
end

--number, number, CrossfadeEvent | CFSpikeEvent | nil, CFSpikeEvent
local function drawSpike(startPPQ, endPPQ, lastEvent, spike)
    local startP = (spike.startPPQ - startPPQ) / (endPPQ - startPPQ)
    local endP = (spike.endPPQ - startPPQ) / (endPPQ - startPPQ)
    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    gfx.set(1,0,0)
    gfx.rect(DEBUG_ORIGIN_X, endY, 10, startY - endY)

    local laneStartY = startY + TRANSITION
    local lastEventPos = nil 

    if lastEvent ~= nil then
        if lastEvent.type == EventType.CROSS then
            lastEventPos = lastEvent.position
        elseif lastEvent.Type == EventType.SPIKE then
            lastEventPos = lastEvent.basePosition
        end
    end

    if lastEventPos ~= nil and lastEventPos ~= spike.basePosition then
        drawCrossfadeGeneral(lastEvent.position, spike.basePosition, startY)
        laneStartY = startY - TRANSITION
    end

    drawLaneGeneral(spike.basePosition, laneStartY, endY)

    if spike.basePosition == CrossfadePos.GREEN then
        -- spike from green to red
        drawImg(IMAGES.SPIKE_G_FRONT_RIGHT_ACTIVE, ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE / 2, startY , 2 * UNIT_SIZE, TRANSITION)
        drawImg(IMAGES.SPIKE_G_BACK_RIGHT_ACTIVE, ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE / 2, startY - TRANSITION, 2 * UNIT_SIZE, TRANSITION)
    elseif spike.basePosition == CrossfadePos.RED then
        if spike.tipPosition == CrossfadePos.GREEN then
            -- spike from red to green
            -- assume both active for now
            drawImg(IMAGES.SPIKE_G_FRONT_LEFT_ACTIVE, ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE / 2, startY, 2 * UNIT_SIZE, TRANSITION)
            drawImg(IMAGES.SPIKE_G_BACK_LEFT_ACTIVE, ORIGIN_X - 2*UNIT_SIZE - UNIT_SIZE / 2, startY - TRANSITION, 2 * UNIT_SIZE, TRANSITION)
        else 
            -- spike from red to blue
            drawImg(IMAGES.SPIKE_B_FRONT_RIGHT_ACTIVE, ORIGIN_X + UNIT_SIZE - UNIT_SIZE / 2, startY, 2 * UNIT_SIZE, TRANSITION)
            drawImg(IMAGES.SPIKE_B_BACK_RIGHT_ACTIVE, ORIGIN_X + UNIT_SIZE - UNIT_SIZE / 2, startY - TRANSITION, 2 * UNIT_SIZE, TRANSITION)
        end
    elseif spike.basePosition == CrossfadePos.BLUE then
        -- spike from blue to red
        drawImg(IMAGES.SPIKE_B_FRONT_LEFT_ACTIVE, ORIGIN_X + UNIT_SIZE - UNIT_SIZE / 2, startY, 2 * UNIT_SIZE, TRANSITION)
        drawImg(IMAGES.SPIKE_B_BACK_LEFT_ACTIVE, ORIGIN_X + UNIT_SIZE - UNIT_SIZE / 2, startY - TRANSITION, 2 * UNIT_SIZE, TRANSITION)
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
            --drawLaneStart(startPPQ, endPPQ, lastEvent, event)
            --drawLaneMiddle(startPPQ, endPPQ, event)
            drawCrossfadeEvent(startPPQ, endPPQ, lastEvent, event)
        elseif event.type == EventType.SPIKE then
            drawSpike(startPPQ, endPPQ, lastEvent, event)
        end
        lastEvent = event
    end
end
