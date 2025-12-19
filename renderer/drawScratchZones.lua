local function drawSingleZoneSegment(startPPQ, endPPQ, zoneSegment, cfPos)
    local startP = math.max(0,(zoneSegment.startPPQ - startPPQ) / (endPPQ - startPPQ))
    local endP = (zoneSegment.endPPQ - startPPQ) / (endPPQ - startPPQ)
    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    if zoneSegment.position == CrossfadePos.GREEN then
        local xOffset = -UNIT
        if cfPos == CrossfadePos.GREEN then
            xOffset = -2*UNIT
        end
        gfx.set(0.05, 0.81, 0.10)
        gfx.rect(ORIGIN_X + xOffset - UNIT/2, endY, UNIT, startY - endY + UNIT / 2)
    elseif zoneSegment.position == CrossfadePos.BLUE then
        local xOffset = UNIT
        if cfPos == CrossfadePos.BLUE then
            xOffset = 2*UNIT
        end
        gfx.set(0.14, 0.66, 0.93)
        gfx.rect(ORIGIN_X + xOffset - UNIT/2, endY, UNIT, startY - endY + UNIT / 2)
    end
end

--number, number, [ScratchZoneEvent], [CrossfadeEvent | CFSpikeEvent]
function drawScratchZones(startPPQ, endPPQ, scratchZones, mergedCross)
    for _, zone in ipairs(scratchZones) do
        --split zone based on mergedCross in order to have separate segments to draw
        local cfPos = getCrossfadePosAt(zone.startPPQ, mergedCross)
        drawSingleZoneSegment(startPPQ, endPPQ, zone, cfPos)
    end                                                            
end                                                                
                                                                   
                                                                   
