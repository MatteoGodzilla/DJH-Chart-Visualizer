require("renderer/sizes")

local function drawSingleEuph(startPPQ, endPPQ, euphoria)
    local startP = math.max(0,(euphoria.startPPQ - startPPQ) / (endPPQ - startPPQ))
    local endP = math.min(1,(euphoria.endPPQ - startPPQ) / (endPPQ - startPPQ))

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    gfx.set(1,1,1, 0.5)
    gfx.rect(ORIGIN_X - 2.5*UNIT, endY, 5*UNIT, startY - endY)
end

function drawEuphoriaZones(startPPQ, endPPQ, euphoria)
    for _,euph in ipairs(euphoria) do
        drawSingleEuph(startPPQ, endPPQ, euph)
    end
end
