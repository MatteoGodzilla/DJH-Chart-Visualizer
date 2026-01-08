--Consider as an enum type
CrossfadePos = {
    GREEN = 0,
    RED = 1,
    BLUE = 2
}

EventType = {
    CROSS = 1,
    SPIKE = 2,
    TAP = 3,
    SCRATCH = 4,
    SCRATCH_ZONE = 5,
    EUPHORIA = 6,
    EFFECTS = 7,
    SECTION = 8,
}

EffectMask = {
    GREEN = 1,
    RED = 2,
    BLUE = 4,
    ALL = 7
}

ScratchDir = {
    UP = 1,
    DOWN = 2,
    ANYDIR = 3
}

--Inheritance Tree
--Event
--| EventWithPos
--| | CrossfadeEvent
--| | | CFSpikeEvent
--| | TapEvent
--| | ScratchEvent
--| | ScratchZoneEvent
--| EuphoriaEvent
--| EffectEvent
--| SectionEvent

local function Event(eventType, startTime, endTime)
    return {
        type = eventType,
        startPPQ = startTime,
        endPPQ = endTime
    }
end

--Pos is one of the available values in CrossfadePos
local function EventWithPos(eventType, startTime, endTime, pos)
    local res = Event(eventType, startTime, endTime)
    res.position = pos
    return res
end

function CrossfadeEvent(startTime, endTime, pos)
    return EventWithPos(EventType.CROSS, startTime, endTime, pos)
end

function CFSpikeEvent(startTime, endTime, basePos, tipPos)
    local res = EventWithPos(EventType.SPIKE, startTime, endTime, basePos)
    res.tipPosition = tipPos
    return res
end

function TapEvent(startTime, endTime, pos)
    return EventWithPos(EventType.TAP, startTime, endTime, pos)
end

function ScratchEvent(startTime, endTime, pos, dir)
    local res = EventWithPos(EventType.SCRATCH, startTime, endTime, pos)
    res.direction = dir
    return res
end

function ScratchZoneEvent(startTime, endTime, pos)
    return EventWithPos(EventType.SCRATCH_ZONE, startTime, endTime, pos)
end

function EuphoriaEvent(startTime, endTime)
    return Event(EventType.EUPHORIA, startTime, endTime)
end

function EffectEvent(startTime, endTime, mask)
    local res = Event(EventType.EFFECTS, startTime, endTime)
    res.mask = mask
    return res
end

function SectionEvent(time, name)
    local res = Event(EventType.SECTION, time, time)
    res.text = name
    return res
end

