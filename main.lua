--Imported functions and variables
require("utils")
local NOTES = require("notes")
local IMAGES = require("images")
local Crossfade = require("Crossfade")

--Constants 
local WIDTH = 800
local HEIGHT = 600
local ORIGIN_X = WIDTH / 2
local ORIGIN_Y = HEIGHT * 4 / 5
--TODO: let the user change this with keyboard bindings
local UNIT_SIZE = 100 --pixels, same for horizontal and vertical


--Other globals
local notesTrack = nil
local effectsTrack = nil

local visibleRangeS = 2.0
local crossfadeWidth = 20 --pixels

local function drawZones(crossfade)
    local HALF = UNIT_SIZE / 2
    drawImg(IMAGES.ZONE_SLOT, ORIGIN_X - UNIT_SIZE * 2 - HALF, ORIGIN_Y - HALF, UNIT_SIZE * 2, UNIT_SIZE)
    drawImg(IMAGES.ZONE_SLOT, ORIGIN_X + UNIT_SIZE - HALF, ORIGIN_Y - HALF, UNIT_SIZE * 2, UNIT_SIZE)

    drawImg(IMAGES.ZONE_R, ORIGIN_X - HALF, ORIGIN_Y - HALF, UNIT_SIZE, UNIT_SIZE)
    local greenOffset = -UNIT_SIZE
    local blueOffset = UNIT_SIZE
    
    if crossfade == Crossfade.GREEN then
        greenOffset = -UNIT_SIZE * 2       
    elseif crossfade == Crossfade.BLUE then
        blueOffset = UNIT_SIZE *2   
    end
    drawImg(IMAGES.ZONE_G, ORIGIN_X + greenOffset - HALF, ORIGIN_Y - HALF, UNIT_SIZE, UNIT_SIZE)
    drawImg(IMAGES.ZONE_B, ORIGIN_X + blueOffset - HALF, ORIGIN_Y - HALF, UNIT_SIZE, UNIT_SIZE)
end

-- This function has to be without arguments because it gets called by reaper itself
-- so the tracks has to be global vars
local function draw()
    gfx.x = 0
    gfx.y = 0

    local playbackTimeS = reaper.GetCursorPositionEx(0)
    if reaper.GetPlayStateEx(0) == 1 then
        playbackTimeS = reaper.GetPlayPositionEx(0)
    end

    local endTimeS = playbackTimeS + visibleRangeS
    local firstCrossfade = nil

    if notesTrack ~= nil then
        local midiItem = reaper.GetTrackMediaItem(notesTrack, 0)
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
                    if pitch == NOTES.CROSS_G then
                        --Crossfade Green
                        local x = gfx.w / 2 - crossfadeWidth - crossfadeWidth / 2
                        local y = (1.0 - startPercentage) * gfx.h
                        local height = (endPercentage - startPercentage) * gfx.h

                        gfx.set(0,1,0)
                        gfx.rect(x,y - height,crossfadeWidth,height)
                        if firstCrossfade == nil then
                            firstCrossfade = Crossfade.GREEN
                        end
                    elseif pitch == NOTES.CROSS_R then
                        --Crossfade Center
                        local x = gfx.w / 2 - crossfadeWidth / 2
                        local y = (1.0 - startPercentage) * gfx.h
                        local height = (endPercentage - startPercentage) * gfx.h

                        gfx.set(1,0,0)
                        gfx.rect(x,y - height,crossfadeWidth,height)
                        if firstCrossfade == nil then
                            firstCrossfade = Crossfade.RED
                        end
                    elseif pitch == NOTES.CROSS_B then
                        --Crossfade Blue
                        local x = gfx.w / 2 + crossfadeWidth - crossfadeWidth / 2
                        local y = (1.0 - startPercentage) * gfx.h
                        local height = (endPercentage - startPercentage) * gfx.h

                        gfx.set(0,0,1)
                        gfx.rect(x,y - height,crossfadeWidth,height)
                        if firstCrossfade == nil then
                            firstCrossfade = Crossfade.BLUE
                        end
                    end

                    --this is just for printing
                    --local startQB = reaper.MIDI_GetProjQNFromPPQPos(midiTake, startPPQPos)
                    --local endQB = reaper.MIDI_GetProjQNFromPPQPos(midiTake, endPPQpos)
                    --gfx.printf("%f \t %f \t %d \t %d", startQB, endQB, pitch, velocity)
                    --gfx.x = 0
                    --gfx.y = gfx.y + gfx.texth
                end
            end
        end

    else
        gfx.printf("NOTES NOT FOUND")
    end

    --NEW
    --TODO: get status of crossfade
    drawZones(firstCrossfade)


    -- debug log
    --gfx.x = 0
    --gfx.y = gfx.h - gfx.texth
    --gfx.set(1,1,1)
    --gfx.drawstr(debugLog)

    gfx.update()

    -- gfx.getchar() returns -1 if the window is closed
    if gfx.getchar() ~= -1 then
        --think of this as JS's RequestAnimationFrame
        reaper.defer(draw)
    end
end

local function main()
    gfx.init("DJH-Chart-Visualizer", WIDTH, HEIGHT)
    gfx.setfont(1, "Arial", 20)

    notesTrack, effectsTrack = getDJHTracks()
    draw()
end

main()
