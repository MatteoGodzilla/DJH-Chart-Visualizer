CrossfadePos = {
    LEFT = 0,
    CENTER = 1,
    RIGHT = 2
}

Lane = {
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
    FS_CROSS = 9,
    FS_CROSS_MARKER = 10,
    FS_SAMPLE = 11,
    FS_SCRATCH = 12,
    MEGAMIX_TRANSITION = 13,
    BATTLE_CHUNKREMIX = 14
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
--[[
Event
    EventWithPos
        CrossfadeEvent
        CFSpikeEvent
    EventInLane
        TapEvent
        ScratchEvent
        ScratchZoneEvent
        FSCrossMarkerEvent
        FSScratchEvent
    EuphoriaEvent
    EffectEvent
    SectionEvent
    FSCrossfadeEvent
    FSSampleEvent
    MegamixTransitionEvent
    BattleChunkRemixEvent
]]

local function Event(eventType, startTime, endTime)
    return {
        type = eventType,
        startPPQ = startTime,
        endPPQ = endTime
    }
end

--Pos is one of the available values in CrossfadePos
function EventWithPos(eventType, startTime, endTime, pos)
    local res = Event(eventType, startTime, endTime)
    res.position = pos
    return res
end

--lane is one of the available values in Lanes
function EventInLane(eventType, startTime, endTime, lane)
    local res = Event(eventType, startTime, endTime)
    res.lane = lane
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

function TapEvent(startTime, endTime, lane)
    return EventInLane(EventType.TAP, startTime, endTime, lane)
end

function ScratchEvent(startTime, endTime, lane, dir)
    local res = EventInLane(EventType.SCRATCH, startTime, endTime, lane)
    res.direction = dir
    return res
end

function ScratchZoneEvent(startTime, endTime, lane)
    return EventInLane(EventType.SCRATCH_ZONE, startTime, endTime, lane)
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

function FSCrossfadeEvent(startTime, endTime)
    return Event(EventType.FS_CROSS, startTime, endTime)
end

function FSCrossMarkerEvent(startTime, endTime, lane)
    return EventInLane(EventType.FS_CROSS_MARKER, startTime, endTime, lane)
end

function FSSampleEvent(startTime, endTime)
    return Event(EventType.FS_SAMPLE, startTime, endTime)
end

function FSScratchEvent(startTime, endTime, lane)
    return EventInLane(EventType.FS_SCRATCH, startTime, endTime, lane)
end

function MegamixTransitionEvent(time)
    return Event(EventType.MEGAMIX_TRANSITION, time, time)
end

function BattleChunkRemixEvent(time)
    return Event(EventType.BATTLE_CHUNKREMIX, time, time)
end
