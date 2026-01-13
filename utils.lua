function getDJHTracks()
    local notes = {}
    local effects = {}
    --find mediatracks
    for i = 0, reaper.CountTracks(0)-1 do
        local track = reaper.GetTrack(0,i)
        local _, name = reaper.GetTrackName(track)
        if string.sub(name, 1,#"NOTES") == "NOTES" then
            table.insert(notes, track)
        elseif string.sub(name,1,8) == "EFFECTS" then
            table.insert(effects, track)
        end
    end
    return notes, efffects
end

--ImageData, number, number, number, number
function drawImg(image, x, y, w, h)
    gfx.a = 1
    gfx.mode = 0
    gfx.blit(image.src, 1, 0, image.srcx, image.srcy, image.srcw, image.srch, x, y, w, h)
end

local logY = 0

function startGlog()
    logY = 0
end

function glog(str)
    gfx.x = 0
    gfx.y = logY
    gfx.set(1,1,1)

    gfx.printf(str.."\n")

    logY = gfx.y + gfx.texth
end

--returns startPPQ, endPPQ, PPQResolution
function getPPQTimes(track, pixelsPerBeat, availableHeight)
    local midiTake = reaper.GetMediaItemTake(reaper.GetTrackMediaItem(track, 0), 0)
    if not reaper.TakeIsMIDI(midiTake) then
        return 0, 1, 960 --just to avoid divisions by 0, this edge case should never happen anyway if used in the djh template
    else
        local playbackTimeS = reaper.GetCursorPositionEx(0)
        if reaper.GetPlayStateEx(0) == 1 then
            playbackTimeS = reaper.GetPlayPositionEx(0)
        end
        local playbackTimePPQ = reaper.MIDI_GetPPQPosFromProjTime(midiTake, playbackTimeS)
        local beatsVisible = availableHeight / pixelsPerBeat

        --local endTimeS = playbackTimeS + rangeS
        --local endTimePPQ = reaper.MIDI_GetPPQPosFromProjTime(midiTake, endTimeS)
        local PPQresolution = reaper.MIDI_GetPPQPosFromProjQN(midiTake, 1)
        local endTimePPQ = playbackTimePPQ + PPQresolution * beatsVisible

        return playbackTimePPQ, endTimePPQ, PPQresolution
    end
end

--number, [CrossfadeEvent | CFSpikeEvent]
function getCrossfadePosAt(ppq, mergedCross)
    for _,cross in ipairs(mergedCross) do
        if cross.startPPQ <= ppq and ppq < cross.endPPQ then
            return cross.position
        end
    end

    return CrossfadePos.RED
end

--Event, Event
function PPQComparator(a, b)
    return a.startPPQ < b.startPPQ
end

--Event, [CrossfadeEvent | CFSpikeEvent] 
--returns [CrossfadeEvent]
function getCrossfadeRegionsInEvent(event, mergedCross)
    local result = {}
   
    for _, cross in ipairs(mergedCross) do
        if event.startPPQ < cross.endPPQ and cross.startPPQ < event.endPPQ then
            -- we have an intersection between the two
            local startPPQ = math.max(event.startPPQ, cross.startPPQ)
            local endPPQ = math.min(event.endPPQ, cross.endPPQ)
            table.insert(result, CrossfadeEvent(startPPQ, endPPQ, cross.position))
        end
    end

    return result
end

--number, number, number
--returns number in range [0,1)
function getPercentage(event, startPPQ, endPPQ)
    return (event - startPPQ) / (endPPQ - startPPQ)
end

function isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ)
    return noteStartPPQ < endPPQ and startPPQ <= noteEndPPQ
end

--CrossfadeEvent, [FSCrossfadeEvent], EventType
--returns [CrossfadeEvent]
function maskCrossfade(crossfade, freestyle, type)
    local bag = {}
    local bag2 = {}
    table.insert(bag, crossfade)
    for i, fs in ipairs(freestyle) do
        if fs.type == type then
            --cut the intervals using fs
            for j, cross in ipairs(bag) do
                --reduce end
                local cut = false
                if cross.startPPQ <= fs.startPPQ and fs.startPPQ <= cross.endPPQ then
                    table.insert(bag2, CrossfadeEvent(cross.startPPQ, fs.startPPQ, cross.position))
                    cut = true
                end
                if cross.startPPQ <= fs.endPPQ and fs.endPPQ <= cross.endPPQ then
                    table.insert(bag2, CrossfadeEvent(fs.endPPQ, cross.endPPQ, cross.position))
                    cut = true
                end
                if fs.startPPQ <= cross.startPPQ and cross.endPPQ <= fs.endPPQ then
                    --freestyle completely contains crossfade
                    cut = true
                end
                if not cut then
                    table.insert(bag2, cross)
                end
            end
            --move from bag2 to bag
            bag = {}
            for _, item in ipairs(bag2) do
                if item.startPPQ < item.endPPQ then
                    table.insert(bag, item)
                end
            end
            bag2 = {}
        end
    end
    table.sort(bag, PPQComparator) 
    return bag
end

function maskCrossfadeWithFSCross(crossfade, freestyle)
    return maskCrossfade(crossfade, freestyle, EventType.FS_CROSS)
end

function maskCrossfadeWithFSSamples(crossfade, freestyle)
    return maskCrossfade(crossfade, freestyle, EventType.FS_SAMPLE_SCRATCH)
end

--NOTE: this does not use any reaper functions (because apparently they don't exist?)
--and it assumes 4/4 time signature
--in the case of djh it's not a problem, but for complex reaper projects with time signature changes
--this WILL desync
function PPQToMeasureBeats(timePPQ, PPQResolution)
    local measureRaw = 1 + timePPQ / PPQResolution / 4
    local measure = math.floor(measureRaw)
    local beatsRaw = measureRaw - measure
    local beat = math.floor(1 + beatsRaw * 4)
    return measure, beat
end
