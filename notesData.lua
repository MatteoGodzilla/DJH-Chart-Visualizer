--Consider as an enum type
CrossfadePos = {
    GREEN = 0,
    RED = 1, 
    BLUE = 2
}

EventType = {
    CROSS = 1,
    SPIKE = 2
}

--Pos is one of the available values in CrossfadePos
function CrossfadeEvent(startTime, endTime, pos)
    return {
        type = EventType.CROSS,
        startPPQ = startTime,
        endPPQ = endTime,
        position = pos
    }
end

function CFSpikeEvent(startTime, endTime, basePos, tipPos)
    return {
        type = EventType.SPIKE,
        startPPQ = startTime,
        endPPQ = endTime,
        basePosition = basePos,
        tipPosition = tipPos
    }
end

