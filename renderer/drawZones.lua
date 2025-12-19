require("renderer/sizes")
local IMAGES = require("images")

--number, [CrossfadeEvent | CFSpikeEvent]
function drawZones(startPPQ, mergedCross)
    local HALF = UNIT / 2
    drawImg(IMAGES.ZONE_SLOT, ORIGIN_X - UNIT * 2 - HALF, ORIGIN_Y - HALF, UNIT * 2, UNIT)
    drawImg(IMAGES.ZONE_SLOT, ORIGIN_X + UNIT - HALF, ORIGIN_Y - HALF, UNIT * 2, UNIT)

    drawImg(IMAGES.ZONE_R, ORIGIN_X - HALF, ORIGIN_Y - HALF, UNIT, UNIT)

    --default to red position
    local greenOffset = -UNIT
    local blueOffset = UNIT

    --assume now mergedCross is never empty
    local first = mergedCross[1]
    if first.type == EventType.CROSS then
        --it is currently on a crossfade
        --assume that 
        if first.position == CrossfadePos.GREEN then
            greenOffset = -UNIT * 2       
        elseif first.position == CrossfadePos.BLUE then
            blueOffset = UNIT *2   
        end
    elseif first.type == EventType.SPIKE then
        --it is currently on a spike

        local animPercent = (startPPQ - first.startPPQ)/(first.endPPQ - first.startPPQ)
        --local triangle = math.max(0, 2 * (0.5 - math.abs(animPercent * 2 - 1)))
        local triangle = math.max(0, (1 - animPercent)^2 )

        if first.position == CrossfadePos.GREEN then
            greenOffset = -2*UNIT + UNIT * triangle
            if first.tipPosition == CrossfadePos.BLUE then
                blueOffset = UNIT + UNIT * triangle
            end
        elseif first.position == CrossfadePos.RED then
            --either red-green-red or red-blue-red
            if first.tipPosition == CrossfadePos.GREEN then
                greenOffset = -UNIT - UNIT * triangle 
            elseif first.tipPosition == CrossfadePos.BLUE then
                blueOffset = UNIT + UNIT * triangle
            end
        elseif first.position == CrossfadePos.BLUE then
            blueOffset = 2*UNIT - UNIT * triangle
            if first.tipPosition == CrossfadePos.GREEN then
                greenOffset = -UNIT - UNIT * triangle
            end
        end
    end

    drawImg(IMAGES.ZONE_G, ORIGIN_X + greenOffset - HALF, ORIGIN_Y - HALF, UNIT, UNIT)
    drawImg(IMAGES.ZONE_B, ORIGIN_X + blueOffset - HALF, ORIGIN_Y - HALF, UNIT, UNIT)
end
