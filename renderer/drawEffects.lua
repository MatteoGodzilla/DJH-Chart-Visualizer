local IMAGES = require("images")
--number, number, EffectsEvent
local function drawEffectZone(startPPQ, endPPQ, effect)
    local startP = math.max(getPercentage(effect.startPPQ,startPPQ, endPPQ))
    local endP = getPercentage(effect.endPPQ,startPPQ, endPPQ)

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    local endY = ORIGIN_Y + endP * (-ORIGIN_Y)

    gfx.set(0.847,0.612,0,0.5)
    if effect.mask & EffectMask.GREEN > 0 then
        gfx.rect(ORIGIN_X - 2.5*UNIT, endY, 2*UNIT, startY - endY)
    end
    if effect.mask & EffectMask.RED > 0 then
        gfx.rect(ORIGIN_X - 0.5*UNIT, endY, UNIT, startY - endY)
    end
    if effect.mask & EffectMask.BLUE > 0 then
        gfx.rect(ORIGIN_X + 0.5*UNIT, endY, 2*UNIT, startY - endY)
    end
    --effects all is visualized with the composition of the three parts
end

--number, number, EffectEvent
local function drawHandle(startPPQ, endPPQ, effect)
    local startP = math.max(0, getPercentage(effect.startPPQ,startPPQ, endPPQ))

    local startY = ORIGIN_Y + startP * (-ORIGIN_Y)
    gfx.set(0,0,1,1) 

    if effect.mask == EffectMask.GREEN then
        drawImg(IMAGES.EFFECTS_HANDLE_GREEN, ORIGIN_X - 2.5*UNIT, startY - EFFECTS_HANDLE_HEIGHT, 2*UNIT, EFFECTS_HANDLE_HEIGHT )
    elseif effect.mask == EffectMask.RED then
        drawImg(IMAGES.EFFECTS_HANDLE_RED, ORIGIN_X - 0.5*UNIT, startY - EFFECTS_HANDLE_HEIGHT, UNIT, EFFECTS_HANDLE_HEIGHT )
    elseif effect.mask == EffectMask.BLUE then
        drawImg(IMAGES.EFFECTS_HANDLE_BLUE, ORIGIN_X + 0.5*UNIT, startY - EFFECTS_HANDLE_HEIGHT, 2*UNIT, EFFECTS_HANDLE_HEIGHT )
    elseif effect.mask == EffectMask.ALL then
        drawImg(IMAGES.EFFECTS_HANDLE_ALL, ORIGIN_X - 2.5*UNIT, startY - EFFECTS_HANDLE_HEIGHT, 5*UNIT, EFFECTS_HANDLE_HEIGHT )
    end
end

--number, number, [EffectsEvent]
function drawEffectsZones(startPPQ, endPPQ, effects)
    for _, evt in ipairs(effects) do
        drawEffectZone(startPPQ, endPPQ, evt)
    end
end

function drawEffectsHandle(startPPQ, endPPQ, effects)
    for _, evt in ipairs(effects) do
        drawHandle(startPPQ, endPPQ, evt)
    end
end

