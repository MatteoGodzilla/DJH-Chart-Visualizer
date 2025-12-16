local IMAGES = require("images")

--number, number, TapEvent, [CrossfadeEvent], [CFSpikeEvent]
local function drawTapTrail(startPPQ, endPPQ, tap, cross, spikes)
end

--number, number, TapEvent, CrossfadePos
local function drawSingleTap(startPPQ, endPPQ, tap, cfPos)
    local startP = (tap.startPPQ - startPPQ) / (endPPQ - startPPQ)
    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)

    if tap.position == CrossfadePos.GREEN then
        local greenXOff = -UNIT
        if cfPos == CrossfadePos.GREEN then
            greenXOff = -2*UNIT
        end
        drawImg(IMAGES.TAP_G_L0, ORIGIN_X + greenXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_G_L1, ORIGIN_X + greenXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_G_L2, ORIGIN_X + greenXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_G_L3, ORIGIN_X + greenXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
    elseif tap.position == CrossfadePos.RED then
        drawImg(IMAGES.TAP_R_L0, ORIGIN_X - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_R_L1, ORIGIN_X - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_R_L2, ORIGIN_X - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_R_L3, ORIGIN_X - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
    elseif tap.position == CrossfadePos.BLUE then
        local blueXOff = UNIT
        if cfPos == CrossfadePos.BLUE then
            blueXOff = 2*UNIT
        end
        drawImg(IMAGES.TAP_B_L0, ORIGIN_X + blueXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_B_L1, ORIGIN_X + blueXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_B_L2, ORIGIN_X + blueXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
        drawImg(IMAGES.TAP_B_L3, ORIGIN_X + blueXOff - UNIT / 2, startY - UNIT / 2, UNIT, UNIT)
    end
end


--number, number, number, [TapEvent], [CrossfadeEvent], [CFSpikeEvent]
function drawTaps(startPPQ, endPPQ, PPQResolution, taps, crossfades, spikes)
    for _, tap in ipairs(taps) do
        local cfPos = getCrossfadePosAt(tap.startPPQ, crossfades, spikes)
        if tap.endPPQ - tap.startPPQ <= PPQResolution / 4 then
            drawSingleTap(startPPQ, endPPQ, tap, cfPos)
        else 
            drawTapTrail(startPPQ, endPPQ, tap, crossfades, spikes)
            drawSingleTap(startPPQ, endPPQ, tap, cfPos)
        end
    end
end
