require("utils")
local IMAGES = require("images")

--number, number, ScratchEvent, [CrossfadeEvent], [CFSpikeEvent]
local function drawScratchTrail(startPPQ, endPPQ, scratch, crossfades, spikes)
end

--number, number, ScratchEvent, CrossfadePos
local function drawSingleScratch(startPPQ, endPPQ, scratch, cfPos)
    local startP = (scratch.startPPQ - startPPQ) / (endPPQ - startPPQ)
    --TODO: figure out a better solution for held scratches
    if startP < 0 then
        return
    end
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
        --glog(string.format("Scratch: %d %d", scratch.position, scratch.direction))
        local cfPos = getCrossfadePosAt(scratch.startPPQ, mergedCross)
        if scratch.endPPQ - scratch.startPPQ <= PPQResolution / 4 then
            drawSingleScratch(startPPQ, endPPQ, scratch, cfPos)
        else
            drawScratchTrail(startPPQ, endPPQ, scratch, crossfades, spikes)
            drawSingleScratch(startPPQ, endPPQ, scratch, cfPos)
        end
    end
end
