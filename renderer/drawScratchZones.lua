local COLORS = require("colors")

local function drawZoneTransition(startPPQ, endPPQ, zone, thisRegion, lastRegion)
    local startP = getPercentage(thisRegion.startPPQ, startPPQ, endPPQ)
    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local alpha = 0.66

    if zone.lane == Lane.GREEN then
        gfx.set(COLORS.GREEN.r, COLORS.GREEN.g, COLORS.GREEN.b, alpha)
        gfx.rect(ORIGIN_X - 2.5*UNIT, startY - TRANSITION, 2 * UNIT, TRANSITION * 2)
    elseif zone.lane == Lane.BLUE then
        gfx.set(COLORS.BLUE.r, COLORS.BLUE.g, COLORS.BLUE.b, alpha)
        gfx.rect(ORIGIN_X + 0.5*UNIT, startY - TRANSITION, 2 * UNIT, TRANSITION * 2)
    end
end

--number, number, ScratchZoneEvent, CrossfadeEvent, boolean
local function drawZoneFill(startPPQ, endPPQ, zone, region, lastRegion, pushStart)
    local startP = math.max(0, getPercentage(region.startPPQ, startPPQ, endPPQ))
    local endP = getPercentage(region.endPPQ, startPPQ, endPPQ)
    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y) + TRANSITION

    if lastRegion == nil then
        startY = startY + UNIT / 2 --because it's the first event
    elseif pushStart then
        startY = startY - TRANSITION
    end

    local alpha = 0.66

    if zone.lane == Lane.GREEN then
        local xOffset = -UNIT
        if region.position == CrossfadePos.LEFT then
            xOffset = -2*UNIT
        end
        gfx.set(COLORS.GREEN.r, COLORS.GREEN.g, COLORS.GREEN.b, alpha)
        gfx.rect(ORIGIN_X + xOffset - UNIT/2, endY, UNIT, startY - endY)
    elseif zone.lane == Lane.BLUE then
        local xOffset = UNIT
        if region.position == CrossfadePos.RIGHT then
            xOffset = 2*UNIT
        end
        gfx.set(COLORS.BLUE.r, COLORS.BLUE.g, COLORS.BLUE.b, alpha)
        gfx.rect(ORIGIN_X + xOffset - UNIT/2, endY, UNIT, startY - endY)
    end
end

--number, number, [ScratchZoneEvent], [CrossfadeEvent]
function drawScratchZones(startPPQ, endPPQ, scratchZones, mergedCross)
    for _, zone in ipairs(scratchZones) do
        local regions = getCrossfadeRegionsInEvent(zone, mergedCross)
        
        local lastRegion = nil
        for _, region in ipairs(regions) do
            local pushStart = false        
    
            if lastRegion ~= nil and lastRegion.position ~= region.position then
                drawZoneTransition(startPPQ, endPPQ, zone, region, lastRegion)
                pushStart = true
            end

            drawZoneFill(startPPQ, endPPQ, zone, region, lastRegion, pushStart)
            lastRegion = region
        end
    end
end
