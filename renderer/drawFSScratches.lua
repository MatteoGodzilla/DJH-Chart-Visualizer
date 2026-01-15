local IMAGES = require("images")

local function drawFSScratchStart(startPPQ, endPPQ, fakeEvent, crossfadePosition)
    local startP = getPercentage(fakeEvent.startPPQ, startPPQ, endPPQ)
    local startY = math.min(ORIGIN_Y + startP * (-ORIGIN_Y), ORIGIN_Y + UNIT / 2)

    if fakeEvent.lane == Lane.GREEN then
        local xOffset = -UNIT
        if crossfadePosition == CrossfadePos.LEFT then
            xOffset = -2*UNIT
        end

        drawImg(IMAGES.FS_SCRATCH_G_START, ORIGIN_X + xOffset - UNIT / 2, startY - UNIT/2, UNIT, UNIT / 2)
        drawImg(IMAGES.SCRATCH_G_ANYDIR, ORIGIN_X + xOffset - UNIT / 2, startY - UNIT, UNIT, UNIT)
    elseif fakeEvent.lane == Lane.BLUE then
        local xOffset = UNIT
        if crossfadePosition == CrossfadePos.RIGHT then
            xOffset = 2*UNIT
        end

        drawImg(IMAGES.FS_SCRATCH_B_START, ORIGIN_X + xOffset - UNIT / 2, startY - UNIT/2, UNIT, UNIT / 2)
        drawImg(IMAGES.SCRATCH_B_ANYDIR, ORIGIN_X + xOffset - UNIT / 2, startY - UNIT, UNIT, UNIT)
    end
end

local function drawFillPixels(startY, endY, fakeEvent, region)
    if fakeEvent.lane == Lane.GREEN then
        local xOffset = -UNIT
        if region.position == CrossfadePos.LEFT then
            xOffset = -2*UNIT
        end
        drawImg(IMAGES.FS_SCRATCH_G_MIDDLE, ORIGIN_X + xOffset - UNIT / 2, endY, UNIT, startY - endY)
    elseif fakeEvent.lane == Lane.BLUE then
        local xOffset = UNIT
        if region.position == CrossfadePos.RIGHT then
            xOffset = 2*UNIT
        end
        drawImg(IMAGES.FS_SCRATCH_B_MIDDLE, ORIGIN_X + xOffset - UNIT / 2, endY, UNIT, startY - endY)
    end
end

local function drawFSScratchFill(startPPQ, endPPQ, fakeEvent, region, pushStart)
    local startP = math.max(0,getPercentage(region.startPPQ, startPPQ, endPPQ))
    local endP = getPercentage(region.endPPQ, startPPQ, endPPQ) 

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y) + UNIT / 2
    
    if pushStart then
        startY = startY - UNIT / 2
    end

    drawFillPixels(startY, endY, fakeEvent, region)
end

local function drawFSScratchNotTransition(startPPQ, endPPQ, fakeEvent, region)
    local startP = getPercentage(region.startPPQ, startPPQ, endPPQ) 
    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)

    drawFillPixels(startY + UNIT / 2, startY, fakeEvent, region)
end

local function drawFSScratchTransition(startPPQ, endPPQ, fakeEvent, lastRegion, thisRegion)
    local startP = getPercentage(thisRegion.startPPQ, startPPQ, endPPQ) 
    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)

    --this is the worst block of lua code i've ever written, wow
    --there HAS to be a better way to code all of these cases, but everything that comes to mind is more complex to understand

    if lastRegion.position == CrossfadePos.LEFT then
        if thisRegion.position == CrossfadePos.CENTER then
            --green to red lane movement
            if fakeEvent.lane == Lane.GREEN then
                --transition from left to right
                drawImg(IMAGES.FS_SCRATCH_G_TO_RIGHT, ORIGIN_X - 2.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            elseif fakeEvent.lane == Lane.BLUE then
                --continue straight on the blue lane
                drawImg(IMAGES.FS_SCRATCH_B_MIDDLE, ORIGIN_X + 0.5*UNIT, startY - UNIT / 2, UNIT, UNIT)
            end

        elseif thisRegion.position == CrossfadePos.RIGHT then
            --green to blue movement
            if fakeEvent.lane == Lane.GREEN then
                --transition from left to right
                drawImg(IMAGES.FS_SCRATCH_G_TO_RIGHT, ORIGIN_X - 2.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            elseif fakeEvent.lane == Lane.BLUE then
                --continue straight on the blue lane
                drawImg(IMAGES.FS_SCRATCH_B_TO_RIGHT, ORIGIN_X + 0.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            end

        end
    elseif lastRegion.position == CrossfadePos.CENTER then
        if thisRegion.position == CrossfadePos.LEFT then
            -- red to green lane movement
            if fakeEvent.lane == Lane.GREEN then
                --transition from center to left
                drawImg(IMAGES.FS_SCRATCH_G_TO_LEFT, ORIGIN_X - 2.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            elseif fakeEvent.lane == Lane.BLUE then
                --continue straight on the blue lane
                drawImg(IMAGES.FS_SCRATCH_B_MIDDLE, ORIGIN_X + 0.5*UNIT, startY - UNIT / 2, UNIT, UNIT)
            end

        elseif thisRegion.position == CrossfadePos.RIGHT then
            --red to blue lane movement
            if fakeEvent.lane == Lane.GREEN then
                --continue straight on the green lane
                drawImg(IMAGES.FS_SCRATCH_G_MIDDLE, ORIGIN_X - 1.5*UNIT, startY - UNIT / 2, UNIT, UNIT)
            elseif fakeEvent.lane == Lane.BLUE then
                --transition from center to right
                drawImg(IMAGES.FS_SCRATCH_B_TO_RIGHT, ORIGIN_X + 0.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            end

        end
    elseif lastRegion.position == CrossfadePos.RIGHT then
        if thisRegion.position == CrossfadePos.LEFT then
            --blue to green lane movement
            if fakeEvent.lane == Lane.GREEN then
                --transition from center to left
                drawImg(IMAGES.FS_SCRATCH_G_TO_LEFT, ORIGIN_X - 2.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            elseif fakeEvent.lane == Lane.BLUE then
                --transition from right to center
                drawImg(IMAGES.FS_SCRATCH_B_TO_LEFT, ORIGIN_X + 0.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            end

        elseif thisRegion.position == CrossfadePos.CENTER then
            --blue to red lane movement
            if fakeEvent.lane == Lane.GREEN then
                --continue straight on the green lane
                drawImg(IMAGES.FS_SCRATCH_G_MIDDLE, ORIGIN_X - 1.5*UNIT, startY - UNIT / 2, UNIT, UNIT)
            elseif fakeEvent.lane == Lane.BLUE then
                --transition from right to center 
                drawImg(IMAGES.FS_SCRATCH_B_TO_LEFT, ORIGIN_X + 0.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            end

        end
    end
end

local function drawFSScratchEnd(startPPQ, endPPQ, fakeEvent, lastEvent)
    local endP = getPercentage(fakeEvent.endPPQ, startPPQ, endPPQ)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    if fakeEvent.lane == Lane.GREEN then
        local xOffset = -UNIT
        if lastEvent.position == CrossfadePos.LEFT then
            xOffset = -2*UNIT
        end

        drawImg(IMAGES.FS_SCRATCH_G_END, ORIGIN_X + xOffset - UNIT / 2, endY, UNIT, UNIT / 2)
    elseif fakeEvent.lane == Lane.BLUE then
        local xOffset = UNIT
        if lastEvent.position == CrossfadePos.RIGHT then
            xOffset = 2*UNIT
        end

        drawImg(IMAGES.FS_SCRATCH_B_END, ORIGIN_X + xOffset - UNIT / 2, endY, UNIT, UNIT / 2)
    end
end

--number, number, Group, Lane, [CrossfadeEvent]
local function drawFSScratch(startPPQ, endPPQ, group, lane, crossfades)
    --fake because this does not actually exist in the midi
    local fakeEvent = EventInLane(EventType.FS_SCRATCH, group.startPPQ, group.endPPQ, lane)
    local crossfadePosition = getCrossfadePosAt(math.max(startPPQ, fakeEvent.startPPQ), crossfades)
    local regions = getCrossfadeRegionsInEvent(fakeEvent, crossfades)
    drawFSScratchStart(startPPQ, endPPQ, fakeEvent, crossfadePosition)

    local lastEvent = nil
    for _,region in ipairs(regions) do
        local pushStart = false
        if lastEvent ~= nil then
            if lastEvent.position ~= region.position then
                drawFSScratchTransition(startPPQ, endPPQ, fakeEvent, lastEvent, region)
                pushStart = true
            else
                drawFSScratchNotTransition(startPPQ, endPPQ, fakeEvent, region)
            end
        end
       
        drawFSScratchFill(startPPQ, endPPQ, fakeEvent, region, pushStart)
        lastEvent = region
    end
    drawFSScratchEnd(startPPQ, endPPQ, fakeEvent, lastEvent)

    for _, other in ipairs(group.events) do
        local markerP = getPercentage(other.startPPQ, startPPQ, endPPQ)
        local markerY = ORIGIN_Y + markerP * (-ORIGIN_Y)
        local cfPos = getCrossfadePosAt(other.startPPQ, crossfades)
        if lane == Lane.GREEN then
            gfx.set(0.051, 0.812, 0.102, 1) 
            local xOffset = -UNIT
            if cfPos == CrossfadePos.LEFT then
                xOffset = -2*UNIT
            end
            gfx.rect(ORIGIN_X + xOffset - GROUP_FS_WIDTH/2, markerY - GROUP_FS_THICKNESS / 2, GROUP_FS_WIDTH, GROUP_FS_THICKNESS)
        elseif lane == Lane.BLUE then
            gfx.set(0.141, 0.659, 0.929, 1) 
            local xOffset = UNIT
            if cfPos == CrossfadePos.RIGHT then
                xOffset = 2*UNIT
            end
            gfx.rect(ORIGIN_X + xOffset - GROUP_FS_WIDTH/2, markerY - GROUP_FS_THICKNESS / 2, GROUP_FS_WIDTH, GROUP_FS_THICKNESS)
        end
    end
end

--number, number, [Event], [CrossfadeEvent]
function drawFSScratches(startPPQ, endPPQ, freestyle, crossfades)
    local green = {}
    local blue = {}

    for _, evt in ipairs(freestyle) do
        if evt.type == EventType.FS_SCRATCH then
            if evt.lane == Lane.GREEN then
                table.insert(green, evt)
            elseif evt.lane == Lane.BLUE then
                table.insert(blue, evt)
            end
        end
    end

    if #green > 0 then
        --group notes 
        local group = createGroup(green[1])
        for i, sample in ipairs(green) do
            if i > 1 then
                if sample.startPPQ == group.endPPQ then
                    group.endPPQ = sample.endPPQ
                    table.insert(group.events, sample)
                else
                    drawFSScratch(startPPQ, endPPQ, group, Lane.GREEN, crossfades)
                    group = createGroup(sample)
                end
            end
        end
        drawFSScratch(startPPQ, endPPQ, group, Lane.GREEN, crossfades)
    end

    if #blue > 0 then
        --group notes 
        local group = createGroup(blue[1])
        for i, sample in ipairs(blue) do
            if i > 1 then
                if sample.startPPQ == group.endPPQ then
                    group.endPPQ = sample.endPPQ
                    table.insert(group.events, sample)
                else
                    drawFSScratch(startPPQ, endPPQ, group, Lane.BLUE, crossfades)
                    group = createGroup(sample)
                end
            end
        end
        drawFSScratch(startPPQ, endPPQ, group, Lane.BLUE, crossfades)
    end
end
