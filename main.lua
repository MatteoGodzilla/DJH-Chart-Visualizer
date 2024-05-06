local notesMediaTrack = nil
local effectsMediaTrack = nil

local function init()
    gfx.init("Hallo", 800, 600)
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

    if notesMediaTrack ~= nil then
        local midiItem = reaper.GetTrackMediaItem(notesMediaTrack, 0)
        local midiTake = reaper.GetMediaItemTake(midiItem, 0)
        if reaper.TakeIsMIDI(midiTake) then
            local _retval, noteCount, _ccEventCount, _textEventCount = reaper.MIDI_CountEvts(midiTake)
            for i=0, noteCount - 1 do
                local _retval, _selected, _muted, startPPQPos, endPPQpos, _channel, pitch, velocity = reaper.MIDI_GetNote(midiTake, i)
                local startInQB = reaper.MIDI_GetProjQNFromPPQPos(midiTake,startPPQPos)
                local endInQB = reaper.MIDI_GetProjQNFromPPQPos(midiTake,endPPQpos)
                gfx.printf("%f \t %f \t %d \t %d", startInQB, endInQB, pitch, velocity)
                gfx.x = 0
                gfx.y = gfx.y + gfx.texth
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
