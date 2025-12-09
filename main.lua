--Imported functions and variables
require("utils")
local NOTES2MIDI = require("notesToMidi")
local IMAGES = require("images")
require("notesData")

--Constants 
--TODO: let the user change this with keyboard bindings
local WIDTH = 800
local HEIGHT = 600
local UNIT_SIZE = 75 --pixels, same for horizontal and vertical
local ORIGIN_X = WIDTH / 2
local ORIGIN_Y = HEIGHT - UNIT_SIZE

--Other globals
local notesTrack = nil
local effectsTrack = nil

local visibleRangeS = 2.0
local crossfadeWidth = 20 --pixels

local function drawZones(startPPQ, crossfades, spikes)
    local HALF = UNIT_SIZE / 2
    drawImg(IMAGES.ZONE_SLOT, ORIGIN_X - UNIT_SIZE * 2 - HALF, ORIGIN_Y - HALF, UNIT_SIZE * 2, UNIT_SIZE)
    drawImg(IMAGES.ZONE_SLOT, ORIGIN_X + UNIT_SIZE - HALF, ORIGIN_Y - HALF, UNIT_SIZE * 2, UNIT_SIZE)

    drawImg(IMAGES.ZONE_R, ORIGIN_X - HALF, ORIGIN_Y - HALF, UNIT_SIZE, UNIT_SIZE)

    local greenOffset = -UNIT_SIZE
    local blueOffset = UNIT_SIZE

    --check to see if the zones are in a spike or not
    --default to "not in a spike" aka in a crossfade
    --also assume that crossfades is never an empty table

    local checkCrossfade = true
    local firstCrossfade = crossfades[1]
    if #spikes > 0 then
       checkCrossfade = (firstCrossfade.startPPQ < spikes[1].startPPQ)   
    end
    
    if checkCrossfade then
        --it is currently on a crossfade
        if firstCrossfade.position == CrossfadePos.GREEN then
            greenOffset = -UNIT_SIZE * 2       
        elseif firstCrossfade.position == CrossfadePos.BLUE then
            blueOffset = UNIT_SIZE *2   
        end
    else
        --it is currently on a spike

        local firstSpike = spikes[1]
        local animPercent = (startPPQ - firstSpike.startPPQ)/(firstSpike.endPPQ - firstSpike.startPPQ)
        local triangle = 2 * (0.5 - math.abs(animPercent - 0.5))

        if firstSpike.basePosition == CrossfadePos.GREEN then
            greenOffset = -2*UNIT_SIZE + UNIT_SIZE * triangle
            if firstSpike.tipPosition == CrossfadePos.BLUE then
                blueOffset = UNIT_SIZE + UNIT_SIZE * triangle
            end
        elseif firstSpike.basePosition == CrossfadePos.RED then
            --either red-green-red or red-blue-red
            if firstSpike.tipPosition == CrossfadePos.GREEN then
                greenOffset = -UNIT_SIZE - UNIT_SIZE * triangle 
            elseif firstSpike.tipPosition == CrossfadePos.BLUE then
                blueOffset = UNIT_SIZE + UNIT_SIZE * triangle
            end
        elseif firstSpike.basePosition == CrossfadePos.BLUE then
            blueOffset = 2*UNIT_SIZE - UNIT_SIZE * triangle
            if firstSpike.tipPosition == CrossfadePos.GREEN then
                greenOffset = -UNIT_SIZE - UNIT_SIZE * triangle
            end
        end

    end
    
    drawImg(IMAGES.ZONE_G, ORIGIN_X + greenOffset - HALF, ORIGIN_Y - HALF, UNIT_SIZE, UNIT_SIZE)
    drawImg(IMAGES.ZONE_B, ORIGIN_X + blueOffset - HALF, ORIGIN_Y - HALF, UNIT_SIZE, UNIT_SIZE)
end

--returns startPPQ, endPPQ
local function getPPQTimes(track)
    local playbackTimeS = reaper.GetCursorPositionEx(0)
    if reaper.GetPlayStateEx(0) == 1 then
        playbackTimeS = reaper.GetPlayPositionEx(0)
    end
    local endTimeS = playbackTimeS + visibleRangeS
    local midiTake = reaper.GetMediaItemTake(reaper.GetTrackMediaItem(track, 0), 0)
    if not reaper.TakeIsMIDI(midiTake) then
        return 0, 1 --just to avoid divisions by 0, this edge case should never happen anyway if used in the djh template
    else 
        local playbackTimePPQ = reaper.MIDI_GetPPQPosFromProjTime(midiTake, playbackTimeS)
        local endTimePPQ = reaper.MIDI_GetPPQPosFromProjTime(midiTake, endTimeS)
        return playbackTimePPQ, endTimePPQ
    end
end

--should not do any drawing, just analysis
local function getNotesInFrame(track, startPPQ, endPPQ)
    if track == nil then
        return nil
    else
        local result = {
            crossfades = {},
            spikes = {}
        } --table of contents
        local midiTake = reaper.GetMediaItemTake(reaper.GetTrackMediaItem(notesTrack, 0), 0)
        if reaper.TakeIsMIDI(midiTake) then
            local _retval, noteCount, _ccEventCount, _textEventCount = reaper.MIDI_CountEvts(midiTake)

            local lastCrossfade = CrossfadePos.RED
            local consecutiveSpikesCount = 0
            local lastAddedSpike = nil

            for i=0, noteCount - 1 do
                local retval, isNoteSelected, isNoteMuted, noteStartPPQ, noteEndPPQ, noteChannel, notePitch, noteVelocity = reaper.MIDI_GetNote(midiTake, i)
                --if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                    --gfx.printf("%f \t %f \t %d \t %d", noteStartPPQ, noteEndPPQ, notePitch, noteVelocity)
                    --gfx.x = 0
                    --gfx.y = gfx.y + gfx.texth

                --check for crossfades
                if notePitch == NOTES2MIDI.CROSS_G then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.crossfades, CrossfadeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.GREEN))
                    end
                    lastCrossfade = CrossfadePos.GREEN
                    consecutiveSpikesCount = 0
                elseif notePitch == NOTES2MIDI.CROSS_R then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.crossfades, CrossfadeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.RED))
                    end
                    lastCrossfade = CrossfadePos.RED
                    consecutiveSpikesCount = 0
                elseif notePitch == NOTES2MIDI.CROSS_B then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.crossfades, CrossfadeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.BLUE))
                    end
                    lastCrossfade = CrossfadePos.BLUE
                    consecutiveSpikesCount = 0
                end

                --check for spikes
                if (notePitch == NOTES2MIDI.SPIKE_G or notePitch == NOTES2MIDI.SPIKE_R or notePitch == NOTES2MIDI.SPIKE_B) and consecutiveSpikesCount == 1 then
                    lastCrossfade = CrossfadePos.RED
                    --need to adjust the first spike, since it could have green or blue set as base
                    lastAddedSpike.basePosition = CrossfadePos.RED
                end

                if notePitch == NOTES2MIDI.SPIKE_G then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        lastAddedSpike = CFSpikeEvent(noteStartPPQ, noteEndPPQ, lastCrossfade, CrossfadePos.GREEN)
                        table.insert(result.spikes, lastAddedSpike) 
                    end
                    consecutiveSpikesCount = consecutiveSpikesCount + 1
                elseif notePitch == NOTES2MIDI.SPIKE_R then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        lastAddedSpike = CFSpikeEvent(noteStartPPQ, noteEndPPQ, lastCrossfade, CrossfadePos.RED)
                        table.insert(result.spikes, lastAddedSpike) 
                    end
                    consecutiveSpikesCount = consecutiveSpikesCount + 1
                elseif notePitch == NOTES2MIDI.SPIKE_B then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        lastAddedSpike = CFSpikeEvent(noteStartPPQ, noteEndPPQ, lastCrossfade, CrossfadePos.BLUE)
                        table.insert(result.spikes, lastAddedSpike) 
                    end
                    consecutiveSpikesCount = consecutiveSpikesCount + 1
                end
                --end
            end
        end
        return result
    end
end

-- This function has to be without arguments because it gets called by reaper itself
-- so the tracks has to be global vars
local function update()
    gfx.x = 0
    gfx.y = 0

    if notesTrack == nil then
        gfx.printf("ERROR: Notes track not found")
    else 
        local startPPQ, endPPQ = getPPQTimes(notesTrack)

        gfx.printf("    Time: %f\t%f", startPPQ, endPPQ)

        gfx.x = 0
        gfx.y = gfx.y + gfx.texth

        local notesInFrame = getNotesInFrame(notesTrack, startPPQ, endPPQ)
        if notesInFrame == nil then
            gfx.printf("ERROR: Could not find compatible midi take")
            gfx.x = 0
            gfx.y = gfx.y + gfx.texth
        else
            for idx, spike in pairs(notesInFrame.spikes) do
                gfx.printf("%d, %d", spike.basePosition, spike.tipPosition)
                gfx.x = 0
                gfx.y = gfx.y + gfx.texth
            end
            --draw stuff
            --NEW
            --TODO: get status of crossfade

            drawZones(startPPQ, notesInFrame.crossfades, notesInFrame.spikes)

        end

    end






    -- debug log
    --gfx.x = 0
    --gfx.y = gfx.h - gfx.texth
    --gfx.set(1,1,1)
    --gfx.drawstr(debugLog)

    gfx.update()

    -- gfx.getchar() returns -1 if the window is closed
    if gfx.getchar() ~= -1 then
        --think of this as JS's RequestAnimationFrame
        reaper.defer(update)
    end
end

local function main()
    gfx.init("DJH-Chart-Visualizer", WIDTH, HEIGHT)
    gfx.setfont(1, "Arial", 20)

    notesTrack, effectsTrack = getDJHTracks()
    update()
end

main()
