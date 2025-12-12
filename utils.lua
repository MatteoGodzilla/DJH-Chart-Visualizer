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

--image is an instance of ImageData
function drawImg(image, x, y, w, h)
    gfx.a = 1
    gfx.mode = 0
    gfx.blit(image.src, 1, 0, image.srcx, image.srcy, image.srcw, image.srch, x, y, w, h)
end

function log(str)
    reaper.ShowConsoleMsg(str.."\n")
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

--returns startPPQ, endPPQ
function getPPQTimes(track, rangeS)
    local playbackTimeS = reaper.GetCursorPositionEx(0)
    if reaper.GetPlayStateEx(0) == 1 then
        playbackTimeS = reaper.GetPlayPositionEx(0)
    end
    local endTimeS = playbackTimeS + rangeS
    local midiTake = reaper.GetMediaItemTake(reaper.GetTrackMediaItem(track, 0), 0)
    if not reaper.TakeIsMIDI(midiTake) then
        return 0, 1 --just to avoid divisions by 0, this edge case should never happen anyway if used in the djh template
    else 
        local playbackTimePPQ = reaper.MIDI_GetPPQPosFromProjTime(midiTake, playbackTimeS)
        local endTimePPQ = reaper.MIDI_GetPPQPosFromProjTime(midiTake, endTimeS)
        return playbackTimePPQ, endTimePPQ
    end
end
