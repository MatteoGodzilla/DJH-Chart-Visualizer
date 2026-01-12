local IMAGES = require("images")

--number, number, number, number
local function drawBeat(startPPQ, endPPQ, PPQresolution, i)
    local timePPQ = i * PPQresolution
    local p = getPercentage(timePPQ, startPPQ, endPPQ)
    local y = ORIGIN_Y + p*(-ORIGIN_Y)

    local size = 8
    if i % 4 == 0 then
        size = size * 2
    end

    drawImg(IMAGES.BEAT_LEFT, ORIGIN_X - 2.5*UNIT - PADDING * 2 - size * 2, y - size, size * 2, size * 2)
    drawImg(IMAGES.BEAT_RIGHT, ORIGIN_X + 2.5*UNIT + PADDING * 2, y - size, size * 2, size * 2)
end

--number, number, number
function drawBeatIndicators(startPPQ, endPPQ, PPQresolution)
    local startQN = math.ceil(startPPQ / PPQresolution)
    local endQN = math.floor(endPPQ / PPQresolution)

    for i=startQN,endQN do
        drawBeat(startPPQ, endPPQ, PPQresolution, i)
    end
end
