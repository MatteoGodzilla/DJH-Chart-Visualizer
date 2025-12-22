--Imported functions and variables
require("utils")
local NOTES2MIDI = require("notesToMidi")
require("notesData")
require("renderer/drawZones")
require("renderer/drawCrossfades")
require("renderer/drawTaps")
require("renderer/drawScratches")
require("renderer/drawScratchZones")
require("renderer/drawEuphoria")

--Other globals
local notesTrack = nil
local effectsTrack = nil

local visibleRangeS = 1.0
local crossfadeWidth = 20 --pixels

local lastFrame = reaper.time_precise()

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
            euphoria = {}
        }
        local midiTake = reaper.GetMediaItemTake(reaper.GetTrackMediaItem(notesTrack, 0), 0)
        if reaper.TakeIsMIDI(midiTake) then
            local _retval, noteCount, _ccEventCount, _textEventCount = reaper.MIDI_CountEvts(midiTake)

            --local lastCrossfade = CrossfadePos.RED
            local crossfadeHistory = { [1] = nil, [2] = nil, [3] = nil}

            for i=0, noteCount - 1 do
                local retval, isNoteSelected, isNoteMuted, noteStartPPQ, noteEndPPQ, noteChannel, notePitch, noteVelocity = reaper.MIDI_GetNote(midiTake, i)

                --check for crossfades
                if notePitch == NOTES2MIDI.CROSS_G then
                    crossfadeHistory[3] = crossfadeHistory[2]
                    crossfadeHistory[2] = crossfadeHistory[1]
                    crossfadeHistory[1] = CrossfadeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.GREEN)
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.crossfades, crossfadeHistory[1])
                    end
                elseif notePitch == NOTES2MIDI.CROSS_R then
                    crossfadeHistory[3] = crossfadeHistory[2]
                    crossfadeHistory[2] = crossfadeHistory[1]
                    crossfadeHistory[1] = CrossfadeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.RED)
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.crossfades, crossfadeHistory[1])
                    end
                elseif notePitch == NOTES2MIDI.CROSS_B then
                    crossfadeHistory[3] = crossfadeHistory[2]
                    crossfadeHistory[2] = crossfadeHistory[1]
                    crossfadeHistory[1] = CrossfadeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.BLUE)
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.crossfades, crossfadeHistory[1])
                    end
                end

                --check for spikes

                if notePitch == NOTES2MIDI.SPIKE_G then
                    crossfadeHistory[3] = crossfadeHistory[2]
                    crossfadeHistory[2] = crossfadeHistory[1]
                    --by default outwards spikes have crossfade center as base position
                    crossfadeHistory[1] = CFSpikeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.RED, CrossfadePos.GREEN)
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.spikes, crossfadeHistory[1]) 
                    end
                elseif notePitch == NOTES2MIDI.SPIKE_R then
                    crossfadeHistory[3] = crossfadeHistory[2]
                    crossfadeHistory[2] = crossfadeHistory[1]
                    crossfadeHistory[1] = CFSpikeEvent(noteStartPPQ, noteEndPPQ, crossfadeHistory[2].position, CrossfadePos.GREEN)
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.spikes, crossfadeHistory[1]) 
                    end
                elseif notePitch == NOTES2MIDI.SPIKE_B then
                    crossfadeHistory[3] = crossfadeHistory[2]
                    crossfadeHistory[2] = crossfadeHistory[1]
                    --by default outwards spikes have crossfade center as base position
                    crossfadeHistory[1] = CFSpikeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.RED, CrossfadePos.BLUE)
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.spikes, crossfadeHistory[1]) 
                    end
                end

                --adjust spikes if needed
                if crossfadeHistory[1] ~= nil and crossfadeHistory[2] ~= nil and crossfadeHistory[3] ~= nil then
                    --if we have a situation like CROSS_G, SPIKE_B, CROSS_G then the middle spike has to be adjusted in order to have base position CROSS_G
                    if crossfadeHistory[2].type == EventType.SPIKE and crossfadeHistory[1].position == crossfadeHistory[3].position then
                        crossfadeHistory[2].position = crossfadeHistory[1].position
                    end
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

                --check for scratch zones
                if notePitch == NOTES2MIDI.SCRATCH_G_ZONE then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.scratchZones, ScratchZoneEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.GREEN))
                    end
                elseif notePitch == NOTES2MIDI.SCRATCH_B_ZONE then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.scratchZones, ScratchZoneEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.BLUE))
                    end
                end

                --check for euphoria
                if notePitch == NOTES2MIDI.EUPHORIA then
                    if noteStartPPQ < endPPQ and startPPQ < noteEndPPQ then
                        table.insert(result.euphoria, EuphoriaEvent(noteStartPPQ, noteEndPPQ))
                    end
                end
            end
        end
        return result
    end
end

--[CrossfadeEvent], [CFSpikeEvent] -> sorted [CrossfadeEvent | CFSpikeEvent] 
local function mergeCrossfadeEvents(crossfades, spikes)
    local result = {}
    for _, crossfade in ipairs(crossfades) do
        --glog(string.format("CROSS: %d %d %d", crossfade.startPPQ, crossfade.endPPQ, crossfade.position))
        table.insert(result, crossfade)
    end
    for _, spike in ipairs(spikes) do
        --glog(string.format("SPIKE: %d %d %d %d", spike.startPPQ, spike.endPPQ, spike.position, spike.tipPosition))
        table.insert(result, spike)
    end

    table.sort(result, PPQComparator)
    return result
end

local function handleKey(key)
    if key == 0 then
        return
    end
    
    if key == 45 then -- Minus key
        visibleRangeS = visibleRangeS * 1.1
    elseif key == 61 then -- Equals key
        visibleRangeS = visibleRangeS / 1.1
    else
        --reaper.ShowMessageBox(tostring(key),"AAA",0)
    end
end

-- This function has to be without arguments because it gets called by reaper itself
-- so the tracks has to be global vars
local function update()
    startGlog()

    local thisFrame = reaper.time_precise()
    if notesTrack == nil then
        gfx.printf("ERROR: Notes track not found")
    else 
        local startPPQ, endPPQ, PPQresolution = getPPQTimes(notesTrack,visibleRangeS)
        local deltaTime = thisFrame - lastFrame
        glog(string.format("%f FPS", 1 / deltaTime))

        local notesInFrame = getNotesInFrame(notesTrack, startPPQ, endPPQ)
        if notesInFrame == nil then
            glog("ERROR: Could not find compatible midi take")
        else
            local mergedCross = mergeCrossfadeEvents(notesInFrame.crossfades, notesInFrame.spikes)
            for _,evt in ipairs(mergedCross) do
                if evt.type == EventType.CROSS then
                    glog(string.format("Cross: %d", evt.position))
                elseif evt.type == EventType.SPIKE then
                    glog(string.format("Spike: %d %d", evt.position, evt.tipPosition))
                end
            end
            --draw stuff
            drawEuphoriaZones(startPPQ, endPPQ, notesInFrame.euphoria)
            drawZones(startPPQ, mergedCross)
            drawCrossfades(startPPQ, endPPQ, mergedCross)
            drawTaps(startPPQ, endPPQ, PPQresolution, notesInFrame.taps, mergedCross)
            drawScratchZones(startPPQ, endPPQ, notesInFrame.scratchZones, mergedCross)
            drawScratches(startPPQ, endPPQ, PPQresolution, notesInFrame.scratches, mergedCross)
        end
    end

    gfx.update()

    lastFrame = thisFrame

    -- gfx.getchar() returns -1 if the window is closed
    local key = gfx.getchar()
    if key ~= -1 then
        --think of this as JS's RequestAnimationFrame
        handleKey(key)
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
