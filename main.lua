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
        gfx.printf("FOUND NOTES")
    else
        gfx.printf("NOTES NOT FOUND")
    end

    gfx.x = 0
    gfx.y = gfx.texth
    if effectsMediaTrack ~= nil then
        gfx.printf("FOUND EFFECTS")
    else
        gfx.printf("EFFECTS NOT FOUND")
    end

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