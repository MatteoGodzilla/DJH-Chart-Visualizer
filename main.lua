--Imported functions and variables
require("utils")
local NOTES2MIDI = require("notesToMidi")
require("notesData")
require("renderer/drawZones")
require("renderer/drawCrossfades")
require("renderer/drawTaps")
require("renderer/drawScratches")

--Other globals
local notesTrack = nil
local effectsTrack = nil

local visibleRangeS = 1.0
local crossfadeWidth = 20 --pixels

--should not do any drawing, just analysis
local function getNotesInFrame(track, startPPQ, endPPQ)
    if track == nil then
        return nil
    else
        local result = {
            crossfades = {},
            spikes = {},
            taps = {},
            scratches = {},
            scratchZones = {},
        }
        local midiTake = reaper.GetMediaItemTake(reaper.GetTrackMediaItem(notesTrack, 0), 0)
        if reaper.TakeIsMIDI(midiTake) then
            local _retval, noteCount, _ccEventCount, _textEventCount = reaper.MIDI_CountEvts(midiTake)

            local lastCrossfade = CrossfadePos.RED
            local consecutiveSpikesCount = 0
            local lastAddedSpike = nil

            for i=0, noteCount - 1 do
                local retval, isNoteSelected, isNoteMuted, noteStartPPQ, noteEndPPQ, noteChannel, notePitch, noteVelocity = reaper.MIDI_GetNote(midiTake, i)

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
                if consecutiveSpikesCount == 1
                    and (notePitch == NOTES2MIDI.SPIKE_G or notePitch == NOTES2MIDI.SPIKE_R or notePitch == NOTES2MIDI.SPIKE_B)
                then
                    lastCrossfade = CrossfadePos.RED
                    --need to adjust the first spike, since it could have green or blue set as base
                    if lastAddedSpike ~= nil then
                        lastAddedSpike.position = CrossfadePos.RED
                    end
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

                --check for taps
                if notePitch == NOTES2MIDI.TAP_G then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.taps, TapEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.GREEN))
                    end
                elseif notePitch == NOTES2MIDI.TAP_R then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.taps, TapEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.RED))
                    end
                elseif notePitch == NOTES2MIDI.TAP_B then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.taps, TapEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.BLUE))
                    end
                end

                --check for scratches
                if notePitch == NOTES2MIDI.SCRATCH_G_UP then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.scratches, ScratchEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.GREEN, ScratchDir.UP))
                    end
                elseif notePitch == NOTES2MIDI.SCRATCH_G_DOWN then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.scratches, ScratchEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.GREEN, ScratchDir.DOWN))
                    end
                elseif notePitch == NOTES2MIDI.SCRATCH_G_ANY then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.scratches, ScratchEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.GREEN, ScratchDir.ANYDIR))
                    end
                elseif notePitch == NOTES2MIDI.SCRATCH_B_UP then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.scratches, ScratchEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.BLUE, ScratchDir.UP))
                    end
                elseif notePitch == NOTES2MIDI.SCRATCH_B_DOWN then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.scratches, ScratchEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.BLUE, ScratchDir.DOWN))
                    end
                elseif notePitch == NOTES2MIDI.SCRATCH_B_ANY then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.scratches, ScratchEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.BLUE, ScratchDir.ANY))
                    end
                end
            end
        end
        return result
    end
end

-- This function has to be without arguments because it gets called by reaper itself
-- so the tracks has to be global vars
local function update()
    startGlog()

    if notesTrack == nil then
        gfx.printf("ERROR: Notes track not found")
    else 
        local startPPQ, endPPQ, PPQresolution = getPPQTimes(notesTrack,visibleRangeS)

        glog(string.format("    Time: %f\t%f\t%f", startPPQ, endPPQ, PPQresolution))

        local notesInFrame = getNotesInFrame(notesTrack, startPPQ, endPPQ)
        if notesInFrame == nil then
            glog("ERROR: Could not find compatible midi take")
        else
            --[[
            for idx, crossfade in ipairs(notesInFrame.crossfades) do
                glog(string.format("%d, %d", crossfade.type, crossfade.position))
            end
            glog("----")
            for idx, spike in ipairs(notesInFrame.spikes) do
                glog(string.format("%d, %d", spike.position, spike.tipPosition))
            end
            for idx, tap in ipairs(notesInFrame.taps) do
                glog(string.format("%d, %d", tap.startPPQ, tap.position))
            end
            ]]--
            --draw stuff
            drawZones(startPPQ, notesInFrame.crossfades, notesInFrame.spikes)
            drawCrossfades(startPPQ, endPPQ, notesInFrame.crossfades, notesInFrame.spikes)
            drawTaps(startPPQ, endPPQ, PPQresolution, notesInFrame.taps, notesInFrame.crossfades, notesInFrame.spikes)
            drawScratches(startPPQ, endPPQ, PPQresolution, notesInFrame.scratches, notesInFrame.crossfades, notesInFrame.spikes)
        end

    end
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
