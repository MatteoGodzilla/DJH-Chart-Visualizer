local IMAGES = require("images")

--number, number, [Event]
function drawOther(startPPQ, endPPQ, other)
    for _, evt in ipairs(other) do
        local p = getPercentage(evt.startPPQ, startPPQ, endPPQ)
        local y = ORIGIN_Y + p * (-ORIGIN_Y)
        local image = nil
        local xOffset = 0

        if evt.type == EventType.MEGAMIX_TRANSITION then
            image = IMAGES.MEGAMIX_LEFT
            xOffset = -2*MARKER_SIZE
        elseif evt.type == EventType.BATTLE_CHUNKREMIX then
            image = IMAGES.BATTLE_LEFT
            xOffset = -1*MARKER_SIZE
        end

        if image ~= nil then
            local left = ORIGIN_X - 2.5*UNIT - PADDING * 2 - MARKER_SIZE * 2
            drawImg(image, left + xOffset, y - MARKER_SIZE, MARKER_SIZE * 2, MARKER_SIZE * 2)
        end
    end
end
