local _, filename = reaper.get_action_context()
local rootFolder = filename:match("(.*[/\\])")
--add root folder to path so that lua can resolve the modules correctly
package.path = package.path .. ";" .. rootFolder .. "?.lua"

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
require("renderer/drawEffects")
require("renderer/drawSections")
require("renderer/drawFSCrossfade")
require("renderer/drawBeatIndicators")
require("renderer/drawFSSamples")
require("renderer/drawFSScratches")
require("renderer/drawOther")

--Other globals
local notesTracks = {}
local effectsTracks = {}
local chosenNotesTrackIndex = 0
local chosenEffectsTrackIndex = 0

local freestyleSampleToLane = {}

--number of beats visible
local pixelsPerBeat = 2*UNIT

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
            euphoria = {},
            effects = {},
            sections = {},
            freestyle = {},
            fsCrossfadeMarkers = {},
            other = {}
        }
        local midiTake = reaper.GetMediaItemTake(reaper.GetTrackMediaItem(track, 0), 0)
        if reaper.TakeIsMIDI(midiTake) then
            local _retval, noteCount, _ccEventCount, textEventCount = reaper.MIDI_CountEvts(midiTake)

            local crossfadeHistory = { [1] = nil, [2] = nil, [3] = nil}

            for i=0, noteCount - 1 do
                local retval, isNoteSelected, isNoteMuted, noteStartPPQ, noteEndPPQ, noteChannel, notePitch, noteVelocity = reaper.MIDI_GetNote(midiTake, i)

                --check for crossfades
                if notePitch == NOTES2MIDI.CROSS_G then
                    crossfadeHistory[3] = crossfadeHistory[2]
                    crossfadeHistory[2] = crossfadeHistory[1]
                    crossfadeHistory[1] = CrossfadeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.LEFT)
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.crossfades, crossfadeHistory[1])
                    end
                elseif notePitch == NOTES2MIDI.CROSS_R then
                    crossfadeHistory[3] = crossfadeHistory[2]
                    crossfadeHistory[2] = crossfadeHistory[1]
                    crossfadeHistory[1] = CrossfadeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.CENTER)
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.crossfades, crossfadeHistory[1])
                    end
                elseif notePitch == NOTES2MIDI.CROSS_B then
                    crossfadeHistory[3] = crossfadeHistory[2]
                    crossfadeHistory[2] = crossfadeHistory[1]
                    crossfadeHistory[1] = CrossfadeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.RIGHT)
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.crossfades, crossfadeHistory[1])
                    end
                end

                --check for spikes

                if notePitch == NOTES2MIDI.SPIKE_G then
                    crossfadeHistory[3] = crossfadeHistory[2]
                    crossfadeHistory[2] = crossfadeHistory[1]
                    --by default outwards spikes have crossfade center as base position
                    crossfadeHistory[1] = CFSpikeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.CENTER, CrossfadePos.LEFT)
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.spikes, crossfadeHistory[1])
                    end
                elseif notePitch == NOTES2MIDI.SPIKE_R then
                    crossfadeHistory[3] = crossfadeHistory[2]
                    crossfadeHistory[2] = crossfadeHistory[1]
                    crossfadeHistory[1] = CFSpikeEvent(noteStartPPQ, noteEndPPQ, crossfadeHistory[2].position, CrossfadePos.CENTER)
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.spikes, crossfadeHistory[1])
                    end
                elseif notePitch == NOTES2MIDI.SPIKE_B then
                    crossfadeHistory[3] = crossfadeHistory[2]
                    crossfadeHistory[2] = crossfadeHistory[1]
                    --by default outwards spikes have crossfade center as base position
                    crossfadeHistory[1] = CFSpikeEvent(noteStartPPQ, noteEndPPQ, CrossfadePos.CENTER, CrossfadePos.RIGHT)
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
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
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.taps, TapEvent(noteStartPPQ, noteEndPPQ, Lane.GREEN))
                    end
                elseif notePitch == NOTES2MIDI.TAP_R then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.taps, TapEvent(noteStartPPQ, noteEndPPQ, Lane.RED))
                    end
                elseif notePitch == NOTES2MIDI.TAP_B then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.taps, TapEvent(noteStartPPQ, noteEndPPQ, Lane.BLUE))
                    end
                end

                --check for scratches
                if notePitch == NOTES2MIDI.SCRATCH_G_UP then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.scratches, ScratchEvent(noteStartPPQ, noteEndPPQ, Lane.GREEN, ScratchDir.UP))
                    end
                elseif notePitch == NOTES2MIDI.SCRATCH_G_DOWN then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.scratches, ScratchEvent(noteStartPPQ, noteEndPPQ, Lane.GREEN, ScratchDir.DOWN))
                    end
                elseif notePitch == NOTES2MIDI.SCRATCH_G_ANY then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.scratches, ScratchEvent(noteStartPPQ, noteEndPPQ, Lane.GREEN, ScratchDir.ANYDIR))
                    end
                elseif notePitch == NOTES2MIDI.SCRATCH_B_UP then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.scratches, ScratchEvent(noteStartPPQ, noteEndPPQ, Lane.BLUE, ScratchDir.UP))
                    end
                elseif notePitch == NOTES2MIDI.SCRATCH_B_DOWN then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.scratches, ScratchEvent(noteStartPPQ, noteEndPPQ, Lane.BLUE, ScratchDir.DOWN))
                    end
                elseif notePitch == NOTES2MIDI.SCRATCH_B_ANY then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.scratches, ScratchEvent(noteStartPPQ, noteEndPPQ, Lane.BLUE, ScratchDir.ANYDIR))
                    end
                end

                --check for scratch zones
                if notePitch == NOTES2MIDI.SCRATCH_G_ZONE then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.scratchZones, ScratchZoneEvent(noteStartPPQ, noteEndPPQ, Lane.GREEN))
                    end
                elseif notePitch == NOTES2MIDI.SCRATCH_B_ZONE then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.scratchZones, ScratchZoneEvent(noteStartPPQ, noteEndPPQ, Lane.BLUE))
                    end
                end

                --check for euphoria
                if notePitch == NOTES2MIDI.EUPHORIA then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.euphoria, EuphoriaEvent(noteStartPPQ, noteEndPPQ))
                    end
                end

                --check for effects
                if notePitch == NOTES2MIDI.EFFECTS_G then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.effects, EffectEvent(noteStartPPQ, noteEndPPQ, EffectMask.GREEN))
                    end
                elseif notePitch == NOTES2MIDI.EFFECTS_R then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.effects, EffectEvent(noteStartPPQ, noteEndPPQ, EffectMask.RED))
                    end
                elseif notePitch == NOTES2MIDI.EFFECTS_B then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.effects, EffectEvent(noteStartPPQ, noteEndPPQ, EffectMask.BLUE))
                    end
                elseif notePitch == NOTES2MIDI.EFFECTS_ALL then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.effects, EffectEvent(noteStartPPQ, noteEndPPQ, EffectMask.ALL))
                    end
                end

                --check for freestyle crossfade 
                if notePitch == NOTES2MIDI.FS_CROSS_ZONE then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.freestyle, FSCrossfadeEvent(noteStartPPQ, noteEndPPQ))
                    end
                elseif notePitch == NOTES2MIDI.FS_SAMPLES_SCRATCHES then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        local lane = freestyleSampleToLane[noteVelocity]
                        if lane == Lane.GREEN then
                            table.insert(result.freestyle, FSScratchEvent(noteStartPPQ, noteEndPPQ, Lane.GREEN))
                        elseif lane == Lane.BLUE then
                            table.insert(result.freestyle, FSScratchEvent(noteStartPPQ, noteEndPPQ, Lane.BLUE))
                        else 
                            table.insert(result.freestyle, FSSampleEvent(noteStartPPQ, noteEndPPQ))
                        end
                    end
                end

                --check for freestyle crossfade markers
                if notePitch == NOTES2MIDI.FS_CROSS_G_MARKER then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.fsCrossfadeMarkers, FSCrossMarkerEvent(noteStartPPQ, noteEndPPQ, Lane.GREEN))
                    end
                elseif notePitch == NOTES2MIDI.FS_CROSS_B_MARKER then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.fsCrossfadeMarkers, FSCrossMarkerEvent(noteStartPPQ, noteEndPPQ, Lane.BLUE))
                    end
                end

                --check for other notes
                if notePitch == NOTES2MIDI.MEGAMIX_TRANSITION then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.other, MegamixTransitionEvent(noteStartPPQ))
                    end
                elseif notePitch == NOTES2MIDI.BATTLE_CHUNKREMIX then
                    if isVisible(noteStartPPQ, noteEndPPQ, startPPQ, endPPQ) then
                        table.insert(result.other, BattleChunkRemixEvent(noteStartPPQ))
                    end
                end

            end

            --get sections
            for i=1, textEventCount do
                local _retval, _selected, _muted, ppqpos, type, msg = reaper.MIDI_GetTextSysexEvt(midiTake, i)
                if type == 1 then
                    if isVisible(ppqpos,ppqpos, startPPQ, endPPQ) then
                        table.insert(result.sections, SectionEvent(ppqpos, msg))
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
        table.insert(result, crossfade)
    end
    for _, spike in ipairs(spikes) do
        table.insert(result, spike)
    end

    table.sort(result, PPQComparator)
    return result
end

local function handleKey(key)
    if key == 0 then
        return
    end

    local FACTOR = 1.1

    if key == 45 then -- Minus key
        pixelsPerBeat = pixelsPerBeat / FACTOR
    elseif key == 61 then -- Equals key
        pixelsPerBeat = pixelsPerBeat * FACTOR
    elseif key == 1919379572 then -- Right Arrow Key
        if chosenNotesTrackIndex + 1 <= #notesTracks then
            chosenNotesTrackIndex = chosenNotesTrackIndex + 1
        end
    elseif key == 1818584692 then -- Left Arrow Key
        if chosenNotesTrackIndex - 1 >= 1 then
            chosenNotesTrackIndex = chosenNotesTrackIndex - 1
        end
    else
        --reaper.ShowMessageBox(tostring(key),"AAA",0)
    end
end

-- This function has to be without arguments because it gets called by reaper itself
-- so the tracks has to be global vars
local function update()
    startGlog()

    notes = notesTracks[chosenNotesTrackIndex]

    local thisFrame = reaper.time_precise()
    if notes == nil then
        glog("ERROR: Notes track not found")
    else
        updateOrigin(gfx.w, gfx.h)
        local startPPQ, endPPQ, PPQresolution = getPPQTimes(notes,pixelsPerBeat, ORIGIN_Y)
        local deltaTime = thisFrame - lastFrame
        glog(string.format("%f FPS", 1 / deltaTime))
        local measure, beat = PPQToMeasureBeats(startPPQ, PPQresolution)
        glog(string.format("Time: %d.%d (%s)", measure, beat, startPPQ))
        local _, trackName = reaper.GetTrackName(notes)
        glog(string.format("Track %d of %d:%s", chosenNotesTrackIndex, #notesTracks, trackName))

        local notesInFrame = getNotesInFrame(notes, startPPQ, endPPQ)
        if notesInFrame == nil then
            glog("ERROR: Could not find compatible midi take")
        else
            local mergedCross = mergeCrossfadeEvents(notesInFrame.crossfades, notesInFrame.spikes)

            --draw stuff
            drawBeatIndicators(startPPQ, endPPQ, PPQresolution)
            drawEuphoriaZones(startPPQ, endPPQ, notesInFrame.euphoria)
            drawEffectsZones(startPPQ, endPPQ, notesInFrame.effects)
            drawZones(startPPQ, mergedCross)
            drawFSCrossfades(startPPQ, endPPQ, notesInFrame.freestyle)
            drawCrossfades(startPPQ, endPPQ, mergedCross, notesInFrame.freestyle)
            drawScratchZones(startPPQ, endPPQ, notesInFrame.scratchZones, mergedCross)
            drawTaps(startPPQ, endPPQ, PPQresolution, notesInFrame.taps, mergedCross)
            drawScratches(startPPQ, endPPQ, PPQresolution, notesInFrame.scratches, mergedCross)
            drawEffectsHandle(startPPQ, endPPQ, notesInFrame.effects)
            drawFSCrossfadeMarkers(startPPQ, endPPQ, notesInFrame.fsCrossfadeMarkers)
            drawFSSamples(startPPQ, endPPQ, notesInFrame.freestyle)
            drawFSScratches(startPPQ, endPPQ, notesInFrame.freestyle, mergedCross)
            drawOther(startPPQ, endPPQ, notesInFrame.other)

            drawSections(startPPQ, endPPQ, notesInFrame.sections)
        end
    end

    gfx.update()

    lastFrame = thisFrame

    -- gfx.getchar() returns -1 if the window is closed
    local key = gfx.getchar()
    if key ~= -1 then
        handleKey(key)
        --think of this as JS's RequestAnimationFrame
        reaper.defer(update)
    end
end

local function parseSampleMap(file)
    local result = {}

    local line = file:read("*line")
    while line ~= nil do
        startI, endI, data = string.find(line,"green%s*=([%s%d]*)")
        if startI ~= nil then
            --we have a match
            for vel in string.gmatch(data, "%d*") do
                if #vel > 0 then
                    result[tonumber(vel)] = Lane.GREEN
                end
            end
        end
        startI, endI, data = string.find(line,"blue%s*=([%s%d]*)")
        if startI ~= nil then
            --we have a match
            for vel in string.gmatch(data, "%d*") do
                if #vel > 0 then
                    result[tonumber(vel)] = Lane.BLUE
                end
            end
        end
        line = file:read("*line")
    end
    return result
end

local function main()
    local WIDTH = 800
    local HEIGHT = 600
    gfx.init("DJH-Chart-Visualizer", WIDTH, HEIGHT)
    gfx.setfont(1, "Arial", 20)

    local sampleMap = reaper.GetProjectPath().."/sampleMap.txt"

    local file = io.open(sampleMap, "r") 
    if file ~= nil then
        freestyleSampleToLane = parseSampleMap(file)
    end
 
    --[[
    for k, v in pairs(freestyleSampleToLane) do
        reaper.ShowMessageBox(string.format("%s -> %d", k, v), "", 0)
    end
    ]]

    notesTracks, effectsTracks = getDJHTracks()
    chosenNotesTrackIndex = 1
    chosenEffectsTrackIndex = 1
    update()
end

main()
