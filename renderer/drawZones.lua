require("renderer/sizes")
local IMAGES = require("images")

function drawZones(startPPQ, crossfades, spikes)
    local HALF = UNIT / 2
    drawImg(IMAGES.ZONE_SLOT, ORIGIN_X - UNIT * 2 - HALF, ORIGIN_Y - HALF, UNIT * 2, UNIT)
    drawImg(IMAGES.ZONE_SLOT, ORIGIN_X + UNIT - HALF, ORIGIN_Y - HALF, UNIT * 2, UNIT)

    drawImg(IMAGES.ZONE_R, ORIGIN_X - HALF, ORIGIN_Y - HALF, UNIT, UNIT)

    --default to red position
    local greenOffset = -UNIT
    local blueOffset = UNIT

    if #crossfades > 0 or #spikes > 0 then 
        --at least one of them is not nil
        local firstCrossfade = crossfades[1]
        local firstSpike = spikes[1]

        local useCrossfade = false
        local useSpike = false

        if firstCrossfade ~= nil and firstSpike ~= nil then
            --check the timing to see which one is important
            if firstCrossfade.startPPQ < firstSpike.startPPQ then
                useCrossfade = true
            else 
                useSpike = true
            end
        elseif firstCrossfade ~= nil then
            useCrossfade = true
        elseif firstSpike ~= nil then
            useSpike = true
        end

        if useCrossfade then
            --it is currently on a crossfade
            --assume that 
            if firstCrossfade.position == CrossfadePos.GREEN then
                greenOffset = -UNIT * 2       
            elseif firstCrossfade.position == CrossfadePos.BLUE then
                blueOffset = UNIT *2   
            end
        elseif useSpike then
            --it is currently on a spike

            local animPercent = (startPPQ - firstSpike.startPPQ)/(firstSpike.endPPQ - firstSpike.startPPQ)
            --local triangle = math.max(0, 2 * (0.5 - math.abs(animPercent * 2 - 1)))
            local triangle = math.max(0, (1 - animPercent)^2 )

            if firstSpike.position == CrossfadePos.GREEN then
                greenOffset = -2*UNIT + UNIT * triangle
                if firstSpike.tipPosition == CrossfadePos.BLUE then
                    blueOffset = UNIT + UNIT * triangle
                end
            elseif firstSpike.position == CrossfadePos.RED then
                --either red-green-red or red-blue-red
                if firstSpike.tipPosition == CrossfadePos.GREEN then
                    greenOffset = -UNIT - UNIT * triangle 
                elseif firstSpike.tipPosition == CrossfadePos.BLUE then
                    blueOffset = UNIT + UNIT * triangle
                end
            elseif firstSpike.position == CrossfadePos.BLUE then
                blueOffset = 2*UNIT - UNIT * triangle
                if firstSpike.tipPosition == CrossfadePos.GREEN then
                    greenOffset = -UNIT - UNIT * triangle
                end
            end
        end
    end
    
    drawImg(IMAGES.ZONE_G, ORIGIN_X + greenOffset - HALF, ORIGIN_Y - HALF, UNIT, UNIT)
    drawImg(IMAGES.ZONE_B, ORIGIN_X + blueOffset - HALF, ORIGIN_Y - HALF, UNIT, UNIT)
end
