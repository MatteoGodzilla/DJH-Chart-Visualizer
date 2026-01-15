local IMAGES = require("images")

--number, number, Group 
local function drawFSSample(startPPQ, endPPQ, group)
    local startP = getPercentage(group.startPPQ, startPPQ, endPPQ)
    local endP = getPercentage(group.endPPQ, startPPQ, endPPQ)

    local startY = math.min(ORIGIN_Y + UNIT / 2, ORIGIN_Y + startP * (-ORIGIN_Y))
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    if startY - endY > UNIT then
        --draw base
        drawImg(IMAGES.FS_SAMPLE_END, ORIGIN_X - UNIT / 2, endY, UNIT, UNIT / 2)
        drawImg(IMAGES.FS_SAMPLE_MIDDLE, ORIGIN_X - UNIT / 2, endY + UNIT / 2, UNIT, startY - endY - UNIT)
        drawImg(IMAGES.FS_SAMPLE_START, ORIGIN_X - UNIT / 2, startY - UNIT / 2, UNIT, UNIT / 2)
    end

    --draw additional markers for all the notes in group
    gfx.set(0.851, 0.078, 0.078, 1) 
    for _, other in ipairs(group.events) do
        local markerP = getPercentage(other.startPPQ, startPPQ, endPPQ)
        local markerY = ORIGIN_Y + markerP * (-ORIGIN_Y)
        gfx.rect(ORIGIN_X - GROUP_FS_WIDTH/2, markerY - GROUP_FS_THICKNESS / 2, GROUP_FS_WIDTH, GROUP_FS_THICKNESS)
    end

end

--number, number, [FSSampleEvent]
function drawFSSamples(startPPQ, endPPQ, freestyle)
    local samples = {}

    for _, evt in ipairs(freestyle) do
        if evt.type == EventType.FS_SAMPLE then
            table.insert(samples, evt)
        end
    end

    if #samples > 0 then
        --group notes 
        local group = createGroup(samples[1])
        --table.insert(group, samples[1])
        for i, sample in ipairs(samples) do
            if i > 1 then
                if sample.startPPQ == group.endPPQ then
                    group.endPPQ = sample.endPPQ
                    table.insert(group.events, sample)
                else
                    drawFSSample(startPPQ, endPPQ, group)
                    group = createGroup(sample)
                end
            end
        end
        drawFSSample(startPPQ, endPPQ, group)
    end

end
