require("renderer/sizes")
require("utils")
local IMAGES = require("images")

-- CrossfadePos, CrossfadePos, number
local function drawCrossfadeGeneral(before, after, Y)
    --the crossfade is drawn as a rectangle where center lies at height Y and total height is 2*TRANSITION
    --In all cases the center lane has the same exact image: LANE_R_ACTIVE

    drawImg(IMAGES.LANE_R_ACTIVE, ORIGIN_X - UNIT/2, Y - TRANSITION, UNIT, 2 * TRANSITION)

    --TODO: handle effects
    if before == CrossfadePos.GREEN then
        if after == CrossfadePos.RED then
            --green to red
            drawImg(IMAGES.CROSS_G_LEFT_FRONT_ACTIVE, ORIGIN_X - 2*UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
            drawImg(IMAGES.CROSS_G_RIGHT_BACK_ACTIVE, ORIGIN_X - UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
            --blue lane inactive -> active
            drawImg(IMAGES.LANE_B_INACTIVE_TO_ACTIVE, ORIGIN_X + UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2 * TRANSITION)
        elseif after == CrossfadePos.BLUE then
            --green to red crossfade
            drawImg(IMAGES.CROSS_G_LEFT_FRONT_ACTIVE, ORIGIN_X - 2*UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
            drawImg(IMAGES.CROSS_G_RIGHT_BACK_INACTIVE, ORIGIN_X - UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
            --red to blue crossfade 
            drawImg(IMAGES.CROSS_B_LEFT_FRONT_INACTIVE, ORIGIN_X + UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
            drawImg(IMAGES.CROSS_B_RIGHT_BACK_ACTIVE, ORIGIN_X + 2 * UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
        end
    elseif before == CrossfadePos.RED then
        if after == CrossfadePos.GREEN then
            --red to green crossfade
            drawImg(IMAGES.CROSS_G_LEFT_BACK_ACTIVE, ORIGIN_X - 2*UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
            drawImg(IMAGES.CROSS_G_RIGHT_FRONT_ACTIVE, ORIGIN_X - UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
            --blue lane active -> inactive
            drawImg(IMAGES.LANE_B_ACTIVE_TO_INACTIVE, ORIGIN_X + UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2 * TRANSITION)
        elseif after == CrossfadePos.BLUE then
            --green lane active -> inactive
            drawImg(IMAGES.LANE_G_ACTIVE_TO_INACTIVE, ORIGIN_X - UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2 * TRANSITION)
            --red to blue crossfade 
            drawImg(IMAGES.CROSS_B_LEFT_FRONT_ACTIVE, ORIGIN_X + UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
            drawImg(IMAGES.CROSS_B_RIGHT_BACK_ACTIVE, ORIGIN_X + 2 * UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
        end
    elseif before == CrossfadePos.BLUE then
        if after == CrossfadePos.GREEN then
            --red to green crossfade
            drawImg(IMAGES.CROSS_G_LEFT_BACK_ACTIVE, ORIGIN_X - 2*UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
            drawImg(IMAGES.CROSS_G_RIGHT_FRONT_INACTIVE, ORIGIN_X - UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
            --blue to red crossfade 
            drawImg(IMAGES.CROSS_B_LEFT_BACK_INACTIVE, ORIGIN_X + UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
            drawImg(IMAGES.CROSS_B_RIGHT_FRONT_ACTIVE, ORIGIN_X + 2 * UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
        elseif after == CrossfadePos.RED then
            --green lane inactive -> active
            drawImg(IMAGES.LANE_G_INACTIVE_TO_ACTIVE, ORIGIN_X - UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2 * TRANSITION)
            --blue to red crossfade 
            drawImg(IMAGES.CROSS_B_LEFT_BACK_ACTIVE, ORIGIN_X + UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
            drawImg(IMAGES.CROSS_B_RIGHT_FRONT_ACTIVE, ORIGIN_X + 2 * UNIT - UNIT / 2, Y - TRANSITION, UNIT, 2*TRANSITION)
        end
    end
end

-- CrossfadePos, number, number
local function drawLaneGeneral(position, startY, endY)
    drawImg(IMAGES.LANE_R_ACTIVE, ORIGIN_X - UNIT / 2, endY, UNIT, startY - endY)
    --default to center position
    local greenXOff = -UNIT
    local blueXOff = UNIT
    local greenImg = IMAGES.LANE_G_ACTIVE
    local blueImg = IMAGES.LANE_B_ACTIVE

    --TODO: handle when effects are available

    if position == CrossfadePos.GREEN then
        greenXOff = -2*UNIT
        blueImg = IMAGES.LANE_B_INACTIVE
    elseif position == CrossfadePos.BLUE then
        blueXOff = 2*UNIT
        greenImg = IMAGES.LANE_G_INACTIVE
    end
    drawImg(greenImg, ORIGIN_X + greenXOff -UNIT / 2, endY, UNIT, startY - endY)
    drawImg(blueImg, ORIGIN_X + blueXOff -UNIT / 2, endY, UNIT, startY - endY)
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

local function getSpikeActiveState(events, spike)
    local before = nil
    local after = nil 
    for _, event in ipairs(events) do
        --get latest event before spike
        if event.startPPQ < spike.startPPQ then
            if before == nil or before.startPPQ < event.startPPQ then
                before = event
            end 
        end
        --get latest event after spike
        if event.startPPQ > spike.startPPQ then
            if after == nil or after.startPPQ > event.startPPQ then
                after = event
            end 
        end
    end

    local beforeActive = true
    local afterActive = true

    if before ~= nil and before.position ~= spike.position then
        beforeActive = false
    end

    if after ~= nil and after.position ~= spike.position then
        afterActive = false
    end
    return beforeActive, afterActive
end

--number, number, CrossfadeEvent | CFSpikeEvent | nil, CFSpikeEvent, bool, bool
local function drawSpike(startPPQ, endPPQ, lastEvent, spike, activeFront, activeBack)
    local startP = (spike.startPPQ - startPPQ) / (endPPQ - startPPQ)
    local endP = (spike.endPPQ - startPPQ) / (endPPQ - startPPQ)
    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    local laneStartY = startY + TRANSITION
    local lastEventPos = nil 

    if lastEvent ~= nil then
        lastEventPos = lastEvent.position
    end

    if lastEventPos ~= nil and lastEventPos ~= spike.position then
        drawCrossfadeGeneral(lastEventPos, spike.position, startY)
        laneStartY = startY - TRANSITION
    end

    drawLaneGeneral(spike.position, laneStartY, endY)

    --TODO: test spikes from a side to the opposite one

    if spike.position == CrossfadePos.GREEN then
        -- spike from green to red
        local frontImage = IMAGES.SPIKE_G_FRONT_RIGHT_INACTIVE
        if activeFront then
            frontImage = IMAGES.SPIKE_G_FRONT_RIGHT_ACTIVE
        end
        local backImage = IMAGES.SPIKE_G_BACK_RIGHT_INACTIVE
        if activeBack then
            backImage = IMAGES.SPIKE_G_BACK_RIGHT_ACTIVE
        end
        drawImg(frontImage, ORIGIN_X - 2*UNIT - UNIT / 2, startY , 2 * UNIT, TRANSITION)
        drawImg(backImage, ORIGIN_X - 2*UNIT - UNIT / 2, startY - TRANSITION, 2 * UNIT, TRANSITION)
    elseif spike.position == CrossfadePos.RED then
        if spike.tipPosition == CrossfadePos.GREEN then
            -- spike from red to green
            local frontImage = IMAGES.SPIKE_G_FRONT_LEFT_INACTIVE
            if activeFront then
                frontImage = IMAGES.SPIKE_G_FRONT_LEFT_ACTIVE
            end
            local backImage = IMAGES.SPIKE_G_BACK_LEFT_INACTIVE
            if activeBack then
                backImage = IMAGES.SPIKE_G_BACK_LEFT_ACTIVE
            end
            drawImg(frontImage, ORIGIN_X - 2*UNIT - UNIT / 2, startY, 2 * UNIT, TRANSITION)
            drawImg(backImage, ORIGIN_X - 2*UNIT - UNIT / 2, startY - TRANSITION, 2 * UNIT, TRANSITION)
        else 
            -- spike from red to blue
            local frontImage = IMAGES.SPIKE_B_FRONT_RIGHT_INACTIVE
            if activeFront then
                frontImage = IMAGES.SPIKE_B_FRONT_RIGHT_ACTIVE
            end
            local backImage = IMAGES.SPIKE_B_BACK_RIGHT_INACTIVE
            if activeBack then
                backImage = IMAGES.SPIKE_B_BACK_RIGHT_ACTIVE
            end
            drawImg(frontImage, ORIGIN_X + UNIT - UNIT / 2, startY, 2 * UNIT, TRANSITION)
            drawImg(backImage, ORIGIN_X + UNIT - UNIT / 2, startY - TRANSITION, 2 * UNIT, TRANSITION)
        end
    elseif spike.position == CrossfadePos.BLUE then
        -- spike from blue to red
        local frontImage = IMAGES.SPIKE_B_FRONT_LEFT_INACTIVE
        if activeFront then
            frontImage = IMAGES.SPIKE_B_FRONT_LEFT_ACTIVE
        end
        local backImage = IMAGES.SPIKE_B_BACK_LEFT_INACTIVE
        if activeBack then
            backImage = IMAGES.SPIKE_B_BACK_LEFT_ACTIVE
        end
        drawImg(frontImage, ORIGIN_X + UNIT - UNIT / 2, startY, 2 * UNIT, TRANSITION)
        drawImg(backImage, ORIGIN_X + UNIT - UNIT / 2, startY - TRANSITION, 2 * UNIT, TRANSITION)
    end
end 

--number, number, [CrossfadeEvent | CFSpikeEvent]
function drawCrossfades(startPPQ, endPPQ, mergedCross)
    local lastEvent = nil

    for _, event in ipairs(mergedCross) do
        if event.type == EventType.CROSS then
            drawCrossfadeEvent(startPPQ, endPPQ, lastEvent, event)
        elseif event.type == EventType.SPIKE then
            local front,back = getSpikeActiveState(mergedCross, event)
            drawSpike(startPPQ, endPPQ, lastEvent, event, front, back)
        end
        lastEvent = event
    end
end
