function getDJHTracks()
    local notes = nil
    local effects = nil
    --find mediatracks
    for i = 0, reaper.CountTracks(0)-1 do
        local track = reaper.GetTrack(0,i)
        local _, name = reaper.GetTrackName(track)
        if name == "NOTES" then
            notes = track
        elseif name == "EFFECTS" then
            effects = track
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
function getPPQTimes(track, rangeS)
    local playbackTimeS = reaper.GetCursorPositionEx(0)
    if reaper.GetPlayStateEx(0) == 1 then
        playbackTimeS = reaper.GetPlayPositionEx(0)
    end
    local endTimeS = playbackTimeS + rangeS
    local midiTake = reaper.GetMediaItemTake(reaper.GetTrackMediaItem(track, 0), 0)
    if not reaper.TakeIsMIDI(midiTake) then
        return 0, 1, 960 --just to avoid divisions by 0, this edge case should never happen anyway if used in the djh template
    else 
        local playbackTimePPQ = reaper.MIDI_GetPPQPosFromProjTime(midiTake, playbackTimeS)
        local endTimePPQ = reaper.MIDI_GetPPQPosFromProjTime(midiTake, endTimeS)
        local PPQresolution = reaper.MIDI_GetPPQPosFromProjQN(midiTake, 1)
        return playbackTimePPQ, endTimePPQ, PPQresolution
    end
end

--number, [CrossfadeEvent], [CFSpikeEvent]
function getCrossfadePosAt(ppq, crossfades, spikes)
    for _,cross in ipairs(crossfades) do
        if cross.startPPQ <= ppq and ppq < cross.endPPQ then
            return cross.position
        end
    end

    for _,spike in ipairs(spikes) do
        if spike.startPPQ <= ppq and ppq < spike.endPPQ then
            return spike.position
        end
    end
    --this should never be hit 
    return CrossfadePos.RED
end
