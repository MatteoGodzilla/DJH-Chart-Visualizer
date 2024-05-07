local notesMediaTrack = nil
local effectsMediaTrack = nil

local visibleRangeS = 2.0
local crossfadeWidth = 20 --pixels

local function init()
    gfx.init("DJH-Chart-Visualizer", 800, 600)
    gfx.setfont(1, "Arial", 20)

    --find mediatracks
    for i = 0, reaper.CountTracks(0)-1 do
        local track = reaper.GetTrack(0,i)
        local _, name = reaper.GetTrackName(track)
        if name == "NOTES" then
            notesMediaTrack = track
        elseif name == "EFFECTS" then
            effectsMediaTrack = track
        end
    end
end

local function draw()
    gfx.x = 0
    gfx.y = 0

    local playbackTimeS = reaper.GetCursorPositionEx(0)
    if reaper.GetPlayStateEx(0) == 1 then
        playbackTimeS = reaper.GetPlayPositionEx(0)
    end

    local endTimeS = playbackTimeS + visibleRangeS

    if notesMediaTrack ~= nil then
        local midiItem = reaper.GetTrackMediaItem(notesMediaTrack, 0)
        local midiTake = reaper.GetMediaItemTake(midiItem, 0)
        if reaper.TakeIsMIDI(midiTake) then
            gfx.printf("    Time: %f", reaper.MIDI_GetProjQNFromPPQPos(midiTake,reaper.MIDI_GetPPQPosFromProjTime(midiTake, playbackTimeS)))
            gfx.x = 0
            gfx.y = gfx.y + gfx.texth

            local playbackTimePPQ = reaper.MIDI_GetPPQPosFromProjTime(midiTake, playbackTimeS)
            local endTimePPQ = reaper.MIDI_GetPPQPosFromProjTime(midiTake, endTimeS)

            local _retval, noteCount, _ccEventCount, _textEventCount = reaper.MIDI_CountEvts(midiTake)
            for i=0, noteCount - 1 do
                local _retval, _selected, _muted, startPPQPos, endPPQpos, _channel, pitch, velocity = reaper.MIDI_GetNote(midiTake, i)
                if startPPQPos < endTimePPQ and playbackTimePPQ < endPPQpos then
                    --we should consider this note since it's visible on screen
                    local startPercentage = (startPPQPos - playbackTimePPQ) / (endTimePPQ - playbackTimePPQ)
                    local endPercentage = (endPPQpos - playbackTimePPQ) / (endTimePPQ - playbackTimePPQ)
                    gfx.set(1,1,1)

                    --Crossfades
                    if pitch == 11 then
                        --Crossfade Green
                        local x = gfx.w / 2 - crossfadeWidth - crossfadeWidth / 2
                        local y = (1.0 - startPercentage) * gfx.h
                        local height = (endPercentage - startPercentage) * gfx.h

                        gfx.set(0,1,0)
                        gfx.rect(x,y - height,crossfadeWidth,height)
                    elseif pitch == 10 then
                        --Crossfade Center
                        local x = gfx.w / 2 - crossfadeWidth / 2
                        local y = (1.0 - startPercentage) * gfx.h
                        local height = (endPercentage - startPercentage) * gfx.h

                        gfx.set(1,0,0)
                        gfx.rect(x,y - height,crossfadeWidth,height)
                    elseif pitch == 9 then
                        --Crossfade Blue
                        local x = gfx.w / 2 + crossfadeWidth - crossfadeWidth / 2
                        local y = (1.0 - startPercentage) * gfx.h
                        local height = (endPercentage - startPercentage) * gfx.h

                        gfx.set(0,0,1)
                        gfx.rect(x,y - height,crossfadeWidth,height)
                    end

                    --this is just for printing
                    local startQB = reaper.MIDI_GetProjQNFromPPQPos(midiTake, startPPQPos)
                    local endQB = reaper.MIDI_GetProjQNFromPPQPos(midiTake, endPPQpos)
                    gfx.printf("%f \t %f \t %d \t %d", startQB, endQB, pitch, velocity)
                    gfx.x = 0
                    gfx.y = gfx.y + gfx.texth
                end
            end
        end

    else
        gfx.printf("NOTES NOT FOUND")
    end

    -- gfx.x = 0
    -- gfx.y = gfx.y + gfx.texth
    -- if effectsMediaTrack ~= nil then
    --     local itemCount = reaper.CountTrackMediaItems(effectsMediaTrack)
    --     gfx.printf("FOUND EFFECTS: %s", itemCount)
    -- else
    --     gfx.printf("EFFECTS NOT FOUND")
    -- end

    gfx.update()

    -- gfx.getchar() returns -1 if the window is closed
    if gfx.getchar() ~= -1 then
        --think of this as JS's RequestAnimationFrame
        reaper.defer(draw)
    end
end

local function main()
    init()
    draw()
end

main()
