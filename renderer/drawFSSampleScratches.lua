local IMAGES = require("images")

--number, number, FSSampleEvent, CrossfadePos
local function drawFSScratch(startPPQ, endPPQ, scratch, position)
    glog(string.format("SCRATCH: %d %d", scratch.velocity, position))
end

--number, number, number, number, [FSSampleEvent]
local function drawFSSample(startPPQ, endPPQ, sampleStart, sampleEnd, group)
    local startP = getPercentage(sampleStart, startPPQ, endPPQ)
    local endP = getPercentage(sampleEnd, startPPQ, endPPQ)

    local startY = math.min(ORIGIN_Y + UNIT / 2, ORIGIN_Y + startP * (-ORIGIN_Y))
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    if startY - endY > UNIT then
        --draw base
        drawImg(IMAGES.FS_SAMPLE_END, ORIGIN_X - UNIT / 2, endY, UNIT, UNIT / 2)
        drawImg(IMAGES.FS_SAMPLE_MIDDLE, ORIGIN_X - UNIT / 2, endY + UNIT / 2, UNIT, startY - endY - UNIT)
        drawImg(IMAGES.FS_SAMPLE_START, ORIGIN_X - UNIT / 2, startY - UNIT / 2, UNIT, UNIT / 2)
    end

    gfx.set(0.851, 0.078, 0.078, 1) 
    local THICKNESS = 4 --pixel
    local WIDTH = UNIT / 2
    for _, other in ipairs(group) do
        local markerP = getPercentage(other.startPPQ, startPPQ, endPPQ)
        local markerY = ORIGIN_Y + markerP * (-ORIGIN_Y)
        gfx.rect(ORIGIN_X - WIDTH/2, markerY - THICKNESS / 2, WIDTH, THICKNESS)
    end

end

--number, number, [FSSampleEvent], {velocity -> CrossfadePos}
function drawFSSampleScratches(startPPQ, endPPQ, sampleScratches, laneMap)
    local scratchGreen = {}
    local samples = {}
    local scratchBlue = {}

    --subdivide events by lane
    for _, event in ipairs(sampleScratches) do
        if event.type == EventType.FS_SAMPLE_SCRATCH then
            local lane = laneMap[event.velocity]
            if lane == CrossfadePos.GREEN then
                table.insert(scratchGreen, event)
                --drawFSScratch(startPPQ, endPPQ, event, CrossfadePos.GREEN)
            elseif lane == CrossfadePos.BLUE then
                table.insert(scratchBlue, event)
                --drawFSScratch(startPPQ, endPPQ, event, CrossfadePos.BLUE)
            else 
                --drawFSSample(startPPQ, endPPQ, event)
                table.insert(samples, event)
            end
        end
    end

    if #samples > 0 then
        --group notes 
        local sampleGroupStart = samples[1].startPPQ
        local sampleGroupEnd = samples[1].endPPQ
        local group = {}
        --table.insert(group, samples[1])
        for i, sample in ipairs(samples) do
            if i > 1 then
                if sample.startPPQ == sampleGroupEnd then
                    sampleGroupEnd = sample.endPPQ
                    table.insert(group, sample)
                else
                    drawFSSample(startPPQ, endPPQ, sampleGroupStart, sampleGroupEnd, group)
                    sampleGroupStart = sample.startPPQ
                    sampleGroupEnd = sample.endPPQ
                    group = {}
                end
            end
        end
        drawFSSample(startPPQ, endPPQ, sampleGroupStart, sampleGroupEnd, group)
    end
end
