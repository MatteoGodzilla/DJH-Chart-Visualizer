require("renderer/sizes")
local IMAGES = require("images")

function drawZones(startPPQ, crossfades, spikes)
    local HALF = UNIT_SIZE / 2
    drawImg(IMAGES.ZONE_SLOT, ORIGIN_X - UNIT_SIZE * 2 - HALF, ORIGIN_Y - HALF, UNIT_SIZE * 2, UNIT_SIZE)
    drawImg(IMAGES.ZONE_SLOT, ORIGIN_X + UNIT_SIZE - HALF, ORIGIN_Y - HALF, UNIT_SIZE * 2, UNIT_SIZE)

    drawImg(IMAGES.ZONE_R, ORIGIN_X - HALF, ORIGIN_Y - HALF, UNIT_SIZE, UNIT_SIZE)

    --default to red position
    local greenOffset = -UNIT_SIZE
    local blueOffset = UNIT_SIZE

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
                greenOffset = -UNIT_SIZE * 2       
            elseif firstCrossfade.position == CrossfadePos.BLUE then
                blueOffset = UNIT_SIZE *2   
            end
        elseif useSpike then
            --it is currently on a spike

            local animPercent = (startPPQ - firstSpike.startPPQ)/(firstSpike.endPPQ - firstSpike.startPPQ)
            local triangle = math.max(0, 2 * (0.5 - math.abs(animPercent * 2 - 1)))

            if firstSpike.basePosition == CrossfadePos.GREEN then
                greenOffset = -2*UNIT_SIZE + UNIT_SIZE * triangle
                if firstSpike.tipPosition == CrossfadePos.BLUE then
                    blueOffset = UNIT_SIZE + UNIT_SIZE * triangle
                end
            elseif firstSpike.basePosition == CrossfadePos.RED then
                --either red-green-red or red-blue-red
                if firstSpike.tipPosition == CrossfadePos.GREEN then
                    greenOffset = -UNIT_SIZE - UNIT_SIZE * triangle 
                elseif firstSpike.tipPosition == CrossfadePos.BLUE then
                    blueOffset = UNIT_SIZE + UNIT_SIZE * triangle
                end
            elseif firstSpike.basePosition == CrossfadePos.BLUE then
                blueOffset = 2*UNIT_SIZE - UNIT_SIZE * triangle
                if firstSpike.tipPosition == CrossfadePos.GREEN then
                    greenOffset = -UNIT_SIZE - UNIT_SIZE * triangle
                end
            end
        end
    end
    
    drawImg(IMAGES.ZONE_G, ORIGIN_X + greenOffset - HALF, ORIGIN_Y - HALF, UNIT_SIZE, UNIT_SIZE)
    drawImg(IMAGES.ZONE_B, ORIGIN_X + blueOffset - HALF, ORIGIN_Y - HALF, UNIT_SIZE, UNIT_SIZE)
end
