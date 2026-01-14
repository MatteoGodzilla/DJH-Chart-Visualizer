local IMAGES = require("images")

local function drawFSScratchStart(startPPQ, endPPQ, fakeEvent, crossfadePosition)
    local startP = getPercentage(fakeEvent.startPPQ, startPPQ, endPPQ)
    local startY = math.min(ORIGIN_Y + startP * (-ORIGIN_Y), ORIGIN_Y + UNIT / 2)

    if fakeEvent.position == CrossfadePos.GREEN then
        local xOffset = -UNIT
        if crossfadePosition == CrossfadePos.GREEN then
            xOffset = -2*UNIT
        end

        drawImg(IMAGES.FS_SCRATCH_G_START, ORIGIN_X + xOffset - UNIT / 2, startY - UNIT/2, UNIT, UNIT / 2)
        drawImg(IMAGES.SCRATCH_G_ANYDIR, ORIGIN_X + xOffset - UNIT / 2, startY - UNIT, UNIT, UNIT)
    elseif fakeEvent.position == CrossfadePos.BLUE then
        local xOffset = UNIT
        if crossfadePosition == CrossfadePos.BLUE then
            xOffset = 2*UNIT
        end

        drawImg(IMAGES.FS_SCRATCH_B_START, ORIGIN_X + xOffset - UNIT / 2, startY - UNIT/2, UNIT, UNIT / 2)
        drawImg(IMAGES.SCRATCH_B_ANYDIR, ORIGIN_X + xOffset - UNIT / 2, startY - UNIT, UNIT, UNIT)
    end
end

local function drawFillPixels(startY, endY, fakeEvent, region)
    if fakeEvent.position == CrossfadePos.GREEN then
        local xOffset = -UNIT
        if region.position == CrossfadePos.GREEN then
            xOffset = -2*UNIT
        end
        drawImg(IMAGES.FS_SCRATCH_G_MIDDLE, ORIGIN_X + xOffset - UNIT / 2, endY, UNIT, startY - endY)
    elseif fakeEvent.position == CrossfadePos.BLUE then
        local xOffset = UNIT
        if region.position == CrossfadePos.BLUE then
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

    if lastRegion.position == CrossfadePos.GREEN then
        if thisRegion.position == CrossfadePos.RED then
            --green to red lane movement
            if fakeEvent.position == CrossfadePos.GREEN then
                --transition from left to right
                drawImg(IMAGES.FS_SCRATCH_G_TO_RIGHT, ORIGIN_X - 2.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            elseif fakeEvent.position == CrossfadePos.BLUE then
                --continue straight on the blue lane
                drawImg(IMAGES.FS_SCRATCH_B_MIDDLE, ORIGIN_X + 0.5*UNIT, startY - UNIT / 2, UNIT, UNIT)
            end

        elseif thisRegion.position == CrossfadePos.BLUE then
            --green to blue movement
            if fakeEvent.position == CrossfadePos.GREEN then
                --transition from left to right
                drawImg(IMAGES.FS_SCRATCH_G_TO_RIGHT, ORIGIN_X - 2.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            elseif fakeEvent.position == CrossfadePos.BLUE then
                --continue straight on the blue lane
                drawImg(IMAGES.FS_SCRATCH_B_TO_RIGHT, ORIGIN_X + 0.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            end

        end
    elseif lastRegion.position == CrossfadePos.RED then
        if thisRegion.position == CrossfadePos.GREEN then
            -- red to green lane movement
            if fakeEvent.position == CrossfadePos.GREEN then
                --transition from center to left
                drawImg(IMAGES.FS_SCRATCH_G_TO_LEFT, ORIGIN_X - 2.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            elseif fakeEvent.position == CrossfadePos.BLUE then
                --continue straight on the blue lane
                drawImg(IMAGES.FS_SCRATCH_B_MIDDLE, ORIGIN_X + 0.5*UNIT, startY - UNIT / 2, UNIT, UNIT)
            end

        elseif thisRegion.position == CrossfadePos.BLUE then
            --red to blue lane movement
            if fakeEvent.position == CrossfadePos.GREEN then
                --continue straight on the green lane
                drawImg(IMAGES.FS_SCRATCH_G_MIDDLE, ORIGIN_X - 1.5*UNIT, startY - UNIT / 2, UNIT, UNIT)
            elseif fakeEvent.position == CrossfadePos.BLUE then
                --transition from center to right
                drawImg(IMAGES.FS_SCRATCH_B_TO_RIGHT, ORIGIN_X + 0.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            end

        end
    elseif lastRegion.position == CrossfadePos.BLUE then
        if thisRegion.position == CrossfadePos.GREEN then
            --blue to green lane movement
            if fakeEvent.position == CrossfadePos.GREEN then
                --transition from center to left
                drawImg(IMAGES.FS_SCRATCH_G_TO_LEFT, ORIGIN_X - 2.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            elseif fakeEvent.position == CrossfadePos.BLUE then
                --transition from right to center
                drawImg(IMAGES.FS_SCRATCH_B_TO_LEFT, ORIGIN_X + 0.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            end

        elseif thisRegion.position == CrossfadePos.RED then
            --blue to red lane movement
            if fakeEvent.position == CrossfadePos.GREEN then
                --continue straight on the green lane
                drawImg(IMAGES.FS_SCRATCH_G_MIDDLE, ORIGIN_X - 1.5*UNIT, startY - UNIT / 2, UNIT, UNIT)
            elseif fakeEvent.position == CrossfadePos.BLUE then
                --transition from right to center 
                drawImg(IMAGES.FS_SCRATCH_B_TO_LEFT, ORIGIN_X + 0.5*UNIT, startY - UNIT / 2, 2 * UNIT, UNIT)
            end

        end
    end
end

local function drawFSScratchEnd(startPPQ, endPPQ, fakeEvent, lastEvent)
    local endP = getPercentage(fakeEvent.endPPQ, startPPQ, endPPQ)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    if fakeEvent.position == CrossfadePos.GREEN then
        local xOffset = -UNIT
        if lastEvent.position == CrossfadePos.GREEN then
            xOffset = -2*UNIT
        end

        drawImg(IMAGES.FS_SCRATCH_G_END, ORIGIN_X + xOffset - UNIT / 2, endY, UNIT, UNIT / 2)
    elseif fakeEvent.position == CrossfadePos.BLUE then
        local xOffset = UNIT
        if lastEvent.position == CrossfadePos.BLUE then
            xOffset = 2*UNIT
        end

        drawImg(IMAGES.FS_SCRATCH_B_END, ORIGIN_X + xOffset - UNIT / 2, endY, UNIT, UNIT / 2)
    end
end

--number, number, Group, CrossfadePos, [CrossfadeEvent]
local function drawFSScratch(startPPQ, endPPQ, group, groupPosition, crossfades)
    --fake because this does not actually exist in the midi
    local fakeEvent = EventWithPos(EventType.FS_SCRATCH, group.startPPQ, group.endPPQ, groupPosition)
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
end

--number, number, [Event], [CrossfadeEvent]
function drawFSScratches(startPPQ, endPPQ, freestyle, crossfades)
    local green = {}
    local blue = {}

    for _, evt in ipairs(freestyle) do
        if evt.type == EventType.FS_SCRATCH then
            if evt.position == CrossfadePos.GREEN then
                table.insert(green, evt)
            elseif evt.position == CrossfadePos.BLUE then
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
                    drawFSScratch(startPPQ, endPPQ, group, CrossfadePos.GREEN, crossfades)
                    group = createGroup(sample)
                end
            end
        end
        drawFSScratch(startPPQ, endPPQ, group, CrossfadePos.GREEN, crossfades)
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
                    drawFSScratch(startPPQ, endPPQ, group, CrossfadePos.BLUE, crossfades)
                    group = createGroup(sample)
                end
            end
        end
        drawFSScratch(startPPQ, endPPQ, group, CrossfadePos.BLUE, crossfades)
    end
end
