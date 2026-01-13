require ("ImageData")

local function getScriptDir()
    local _, filename = reaper.get_action_context()
    --regex to remove the last part of the filename, which contains images.lua
    --basic idea: capture all chars before the /
    --since matching is greedy, it gets up until the last directory
    return filename:match("(.*[/\\])")
end

local baseDir = getScriptDir() .. "images/"
local tapsImage       = gfx.loadimg( 0, baseDir.."taps.png")
local zonesImage      = gfx.loadimg( 1, baseDir.."zones.png")
local crossImage      = gfx.loadimg( 2, baseDir.."cross.png")
local laneImage       = gfx.loadimg( 3, baseDir.."lanes.png")
local greenSpikes     = gfx.loadimg( 4, baseDir.."greenSpikes.png")
local blueSpikes      = gfx.loadimg( 5, baseDir.."blueSpikes.png")
local greenCrossfade  = gfx.loadimg( 6, baseDir.."greenCrossfades.png")
local blueCrossfade   = gfx.loadimg( 7, baseDir.."blueCrossfades.png")
local scratches       = gfx.loadimg( 8, baseDir.."scratches.png")
local greenLane       = gfx.loadimg( 9, baseDir.."greenLaneTransitions.png")
local redLane         = gfx.loadimg(10, baseDir.."redLaneTransitions.png")
local blueLane        = gfx.loadimg(11, baseDir.."blueLaneTransitions.png")
local greenTapTrail   = gfx.loadimg(12, baseDir.."greenTapTrail.png")
local redTapTrail     = gfx.loadimg(13, baseDir.."redTapTrail.png")
local blueTapTrail    = gfx.loadimg(14, baseDir.."blueTapTrail.png")
local scratchTrail    = gfx.loadimg(15, baseDir.."scratchTrail.png")
local effectsHandle   = gfx.loadimg(16, baseDir.."effectsHandle.png")
local fsCrossGreen    = gfx.loadimg(17, baseDir.."fsCrossfadeGreen.png")
local fsCrossBlue     = gfx.loadimg(18, baseDir.."fsCrossfadeBlue.png")
local beatMarker      = gfx.loadimg(19, baseDir.."beatMarker.png")
local rewindMarker    = gfx.loadimg(20, baseDir.."rewindMarker.png")
local fsSampleRed     = gfx.loadimg(21, baseDir.."fsSampleRed.png")

local u = 512

--TODO: hold tap trail
--TODO: freestyle
return {
    TAP_G_L0 = ImageData(tapsImage,0*u,0*u,1*u,1*u),
    TAP_G_L1 = ImageData(tapsImage,1*u,0*u,1*u,1*u),
    TAP_G_L2 = ImageData(tapsImage,2*u,0*u,1*u,1*u),
    TAP_G_L3 = ImageData(tapsImage,3*u,0*u,1*u,1*u),

    TAP_R_L0 = ImageData(tapsImage,0*u,1*u,1*u,1*u),
    TAP_R_L1 = ImageData(tapsImage,1*u,1*u,1*u,1*u),
    TAP_R_L2 = ImageData(tapsImage,2*u,1*u,1*u,1*u),
    TAP_R_L3 = ImageData(tapsImage,3*u,1*u,1*u,1*u),

    TAP_B_L0 = ImageData(tapsImage,0*u,2*u,1*u,1*u),
    TAP_B_L1 = ImageData(tapsImage,1*u,2*u,1*u,1*u),
    TAP_B_L2 = ImageData(tapsImage,2*u,2*u,1*u,1*u),
    TAP_B_L3 = ImageData(tapsImage,3*u,2*u,1*u,1*u),

    ZONE_G    = ImageData(zonesImage,0*u,0*u,1*u,1*u),
    ZONE_R    = ImageData(zonesImage,1*u,0*u,1*u,1*u),
    ZONE_B    = ImageData(zonesImage,2*u,0*u,1*u,1*u),
    ZONE_SLOT = ImageData(zonesImage,0*u,1*u,2*u,1*u),

    --lane textures
    --for when no events are changing the sides
    LANE_G_ACTIVE   = ImageData(laneImage,0*u,0*u,1*u,1*u), --vertical stretch
    LANE_G_EFFECTS  = ImageData(laneImage,1*u,0*u,1*u,1*u), --vertical stretch
    LANE_G_INACTIVE = ImageData(laneImage,2*u,0*u,1*u,1*u), --vertical stretch

    LANE_R_ACTIVE   = ImageData(laneImage,0*u,1*u,1*u,1*u), --vertical stretch
    LANE_R_EFFECTS  = ImageData(laneImage,1*u,1*u,1*u,1*u), --vertical stretch
    LANE_R_INACTIVE = ImageData(laneImage,2*u,1*u,1*u,1*u), --vertical stretch

    LANE_B_ACTIVE   = ImageData(laneImage,0*u,2*u,1*u,1*u), --vertical stretch
    LANE_B_EFFECTS  = ImageData(laneImage,1*u,2*u,1*u,1*u), --vertical stretch
    LANE_B_INACTIVE = ImageData(laneImage,2*u,2*u,1*u,1*u), --vertical stretch

    --transitions from a lane state to another
    LANE_G_ACTIVE_TO_EFFECTS   = ImageData(greenLane, 1*u, 1*u/2, u, u/2),
    LANE_G_ACTIVE_TO_INACTIVE  = ImageData(greenLane, 0*u, 0*u/2, u, u/2),
    LANE_G_EFFECTS_TO_ACTIVE   = ImageData(greenLane, 1*u, 0*u/2, u, u/2),
    LANE_G_EFFECTS_TO_INACTIVE = ImageData(greenLane, 2*u, 0*u/2, u, u/2),
    LANE_G_INACTIVE_TO_ACTIVE  = ImageData(greenLane, 0*u, 1*u/2, u, u/2),
    LANE_G_INACTIVE_TO_EFFECTS = ImageData(greenLane, 2*u, 1*u/2, u, u/2),

    LANE_R_ACTIVE_TO_EFFECTS   = ImageData(redLane, 1*u, 1*u/2, u, u/2),
    LANE_R_ACTIVE_TO_INACTIVE  = ImageData(redLane, 0*u, 0*u/2, u, u/2),
    LANE_R_EFFECTS_TO_ACTIVE   = ImageData(redLane, 1*u, 0*u/2, u, u/2),
    LANE_R_EFFECTS_TO_INACTIVE = ImageData(redLane, 2*u, 0*u/2, u, u/2),
    LANE_R_INACTIVE_TO_ACTIVE  = ImageData(redLane, 0*u, 1*u/2, u, u/2),
    LANE_R_INACTIVE_TO_EFFECTS = ImageData(redLane, 2*u, 1*u/2, u, u/2),

    LANE_B_ACTIVE_TO_EFFECTS   = ImageData(blueLane, 1*u, 1*u/2, u, u/2),
    LANE_B_ACTIVE_TO_INACTIVE  = ImageData(blueLane, 0*u, 0*u/2, u, u/2),
    LANE_B_EFFECTS_TO_ACTIVE   = ImageData(blueLane, 1*u, 0*u/2, u, u/2),
    LANE_B_EFFECTS_TO_INACTIVE = ImageData(blueLane, 2*u, 0*u/2, u, u/2),
    LANE_B_INACTIVE_TO_ACTIVE  = ImageData(blueLane, 0*u, 1*u/2, u, u/2),
    LANE_B_INACTIVE_TO_EFFECTS = ImageData(blueLane, 2*u, 1*u/2, u, u/2),

    --Front: part that is earlier in time (visually at the bottom of the window)
    --Imagine you are in the zones and the note is facing you

    --crossfade for left side
    CROSS_G_LEFT_BACK_ACTIVE     = ImageData(greenCrossfade,0*u,0*u,u,u),
    CROSS_G_LEFT_BACK_EFFECTS    = ImageData(greenCrossfade,2*u,0*u,u,u),
    --CROSS_G_LEFT_BACK_INACTIVE   = ImageData(greenCrossfade,4*u,0*u,u,u), --does not make sense
    CROSS_G_RIGHT_BACK_ACTIVE    = ImageData(greenCrossfade,1*u,1*u,u,u),
    CROSS_G_RIGHT_BACK_EFFECTS   = ImageData(greenCrossfade,3*u,1*u,u,u),
    CROSS_G_RIGHT_BACK_INACTIVE  = ImageData(greenCrossfade,5*u,1*u,u,u),
    CROSS_G_LEFT_FRONT_ACTIVE    = ImageData(greenCrossfade,0*u,1*u,u,u),
    CROSS_G_LEFT_FRONT_EFFECTS   = ImageData(greenCrossfade,2*u,1*u,u,u),
    --CROSS_G_LEFT_FRONT_INACTIVE  = ImageData(greenCrossfade,4*u,1*u,u,u), --does not make sense
    CROSS_G_RIGHT_FRONT_ACTIVE   = ImageData(greenCrossfade,1*u,0*u,u,u),
    CROSS_G_RIGHT_FRONT_EFFECTS  = ImageData(greenCrossfade,3*u,0*u,u,u),
    CROSS_G_RIGHT_FRONT_INACTIVE = ImageData(greenCrossfade,5*u,0*u,u,u),

    --crossfade for right side
    CROSS_B_LEFT_BACK_ACTIVE     = ImageData(blueCrossfade,0*u,0*u,u,u),
    CROSS_B_LEFT_BACK_EFFECTS    = ImageData(blueCrossfade,2*u,0*u,u,u),
    CROSS_B_LEFT_BACK_INACTIVE   = ImageData(blueCrossfade,4*u,0*u,u,u),
    CROSS_B_RIGHT_BACK_ACTIVE    = ImageData(blueCrossfade,1*u,1*u,u,u),
    CROSS_B_RIGHT_BACK_EFFECTS   = ImageData(blueCrossfade,3*u,1*u,u,u),
    --CROSS_B_RIGHT_BACK_INACTIVE  = ImageData(blueCrossfade,5*u,1*u,u,u), --does not make sense
    CROSS_B_LEFT_FRONT_ACTIVE    = ImageData(blueCrossfade,0*u,1*u,u,u),
    CROSS_B_LEFT_FRONT_EFFECTS   = ImageData(blueCrossfade,2*u,1*u,u,u),
    CROSS_B_LEFT_FRONT_INACTIVE  = ImageData(blueCrossfade,4*u,1*u,u,u),
    CROSS_B_RIGHT_FRONT_ACTIVE   = ImageData(blueCrossfade,1*u,0*u,u,u),
    CROSS_B_RIGHT_FRONT_EFFECTS  = ImageData(blueCrossfade,3*u,0*u,u,u),
    --CROSS_B_RIGHT_FRONT_INACTIVE = ImageData(blueCrossfade,5*u,0*u,u,u), --does not make sense

    --spikes for the left side
    SPIKE_G_BACK_LEFT_ACTIVE     = ImageData(greenSpikes,0*u ,0*u,2*u,u/2),
    SPIKE_G_BACK_LEFT_EFFECTS    = ImageData(greenSpikes,2*u ,0*u,2*u,u/2),
    SPIKE_G_BACK_LEFT_INACTIVE   = ImageData(greenSpikes,4*u ,0*u,2*u,u/2),
    SPIKE_G_BACK_RIGHT_ACTIVE    = ImageData(greenSpikes,10*u ,0*u,2*u,u/2),
    SPIKE_G_BACK_RIGHT_EFFECTS   = ImageData(greenSpikes,8*u ,0*u,2*u,u/2),
    SPIKE_G_BACK_RIGHT_INACTIVE  = ImageData(greenSpikes,6*u,0*u,2*u,u/2),
    SPIKE_G_FRONT_LEFT_ACTIVE    = ImageData(greenSpikes,0*u ,u/2,2*u,u/2),
    SPIKE_G_FRONT_LEFT_EFFECTS   = ImageData(greenSpikes,2*u ,u/2,2*u,u/2),
    SPIKE_G_FRONT_LEFT_INACTIVE  = ImageData(greenSpikes,4*u ,u/2,2*u,u/2),
    SPIKE_G_FRONT_RIGHT_ACTIVE   = ImageData(greenSpikes,10*u ,u/2,2*u,u/2),
    SPIKE_G_FRONT_RIGHT_EFFECTS  = ImageData(greenSpikes,8*u ,u/2,2*u,u/2),
    SPIKE_G_FRONT_RIGHT_INACTIVE = ImageData(greenSpikes,6*u,u/2,2*u,u/2),

    --spikes for the right side
    SPIKE_B_BACK_LEFT_ACTIVE     = ImageData(blueSpikes,0*u ,0*u,2*u,u/2),
    SPIKE_B_BACK_LEFT_EFFECTS    = ImageData(blueSpikes,2*u ,0*u,2*u,u/2),
    SPIKE_B_BACK_LEFT_INACTIVE   = ImageData(blueSpikes,4*u ,0*u,2*u,u/2),
    SPIKE_B_BACK_RIGHT_ACTIVE    = ImageData(blueSpikes,10*u ,0*u,2*u,u/2),
    SPIKE_B_BACK_RIGHT_EFFECTS   = ImageData(blueSpikes,8*u ,0*u,2*u,u/2),
    SPIKE_B_BACK_RIGHT_INACTIVE  = ImageData(blueSpikes,6*u,0*u,2*u,u/2),
    SPIKE_B_FRONT_LEFT_ACTIVE    = ImageData(blueSpikes,0*u ,u/2,2*u,u/2),
    SPIKE_B_FRONT_LEFT_EFFECTS   = ImageData(blueSpikes,2*u ,u/2,2*u,u/2),
    SPIKE_B_FRONT_LEFT_INACTIVE  = ImageData(blueSpikes,4*u ,u/2,2*u,u/2),
    SPIKE_B_FRONT_RIGHT_ACTIVE   = ImageData(blueSpikes,10*u ,u/2,2*u,u/2),
    SPIKE_B_FRONT_RIGHT_EFFECTS  = ImageData(blueSpikes,8*u ,u/2,2*u,u/2),
    SPIKE_B_FRONT_RIGHT_INACTIVE = ImageData(blueSpikes,6*u,u/2,2*u,u/2),

    --scratches
    SCRATCH_G_UP     = ImageData(scratches, 1*u, 0*u, u, u),
    SCRATCH_G_DOWN   = ImageData(scratches, 2*u, 0*u, u, u),
    SCRATCH_G_ANYDIR = ImageData(scratches, 0*u, 0*u, u, u),

    SCRATCH_B_UP     = ImageData(scratches, 1*u, 0*u, u, u),
    SCRATCH_B_DOWN   = ImageData(scratches, 2*u, 0*u, u, u),
    SCRATCH_B_ANYDIR = ImageData(scratches, 0*u, 0*u, u, u),

    --tap trail 
    TAP_TRAIL_G_FILL     = ImageData(greenTapTrail, 0*u, 0*u, 1*u, 1*u),
    TAP_TRAIL_G_TO_LEFT  = ImageData(greenTapTrail, 2*u, 0*u, 2*u, 1*u),
    TAP_TRAIL_G_TO_RIGHT = ImageData(greenTapTrail, 4*u, 0*u, 2*u, 1*u),
    TAP_TRAIL_G_END      = ImageData(greenTapTrail, 1*u, 0*u, 1*u, 1*u),

    TAP_TRAIL_R_FILL     = ImageData(redTapTrail, 0*u, 0*u, 1*u, 1*u),
    --TAP_TRAIL_R_TO_LEFT  = ImageData(redTapTrail, 2*u, 0*u, 2*u, 1*u),
    --TAP_TRAIL_R_TO_RIGHT = ImageData(redTapTrail, 4*u, 0*u, 2*u, 1*u),
    TAP_TRAIL_R_END      = ImageData(redTapTrail, 1*u, 0*u, 1*u, 1*u),

    TAP_TRAIL_B_FILL     = ImageData(blueTapTrail, 0*u, 0*u, 1*u, 1*u),
    TAP_TRAIL_B_TO_LEFT  = ImageData(blueTapTrail, 2*u, 0*u, 2*u, 1*u),
    TAP_TRAIL_B_TO_RIGHT = ImageData(blueTapTrail, 4*u, 0*u, 2*u, 1*u),
    TAP_TRAIL_B_END      = ImageData(blueTapTrail, 1*u, 0*u, 1*u, 1*u),

    --scratch trail 
    SCRATCH_TRAIL_FILL     = ImageData(scratchTrail, 0*u, 0*u, 1*u, 1*u),
    SCRATCH_TRAIL_TO_LEFT  = ImageData(scratchTrail, 2*u, 0*u, 2*u, 1*u),
    SCRATCH_TRAIL_TO_RIGHT = ImageData(scratchTrail, 4*u, 0*u, 2*u, 1*u),
    SCRATCH_TRAIL_END      = ImageData(scratchTrail, 1*u, 0*u, 1*u, 1*u),

    EFFECTS_HANDLE_GREEN = ImageData(effectsHandle, 0*u, 0  *u, 2*u, 0.5*u),
    EFFECTS_HANDLE_RED   = ImageData(effectsHandle, 2*u, 0  *u, 1*u, 0.5*u),
    EFFECTS_HANDLE_BLUE  = ImageData(effectsHandle, 3*u, 0  *u, 2*u, 0.5*u),
    EFFECTS_HANDLE_ALL   = ImageData(effectsHandle, 0*u, 0.5*u, 5*u, 0.5*u),

    --freestyle crossfade
    FS_CROSS_G_ZONE_END    = ImageData(fsCrossGreen, 1*u,    0*u, 2*u, 0.25*u),
    FS_CROSS_G_ZONE_MIDDLE = ImageData(fsCrossGreen, 1*u, 0.25*u, 2*u, 0.5 *u),
    FS_CROSS_G_ZONE_START  = ImageData(fsCrossGreen, 1*u, 0.75*u, 2*u, 0.25*u),
    FS_CROSS_B_ZONE_END    = ImageData(fsCrossBlue , 1*u,    0*u, 2*u, 0.25*u),
    FS_CROSS_B_ZONE_MIDDLE = ImageData(fsCrossBlue , 1*u, 0.25*u, 2*u, 0.5 *u),
    FS_CROSS_B_ZONE_START  = ImageData(fsCrossBlue , 1*u, 0.75*u, 2*u, 0.25*u),

    FS_CROSS_G_MARKER_END    = ImageData(fsCrossGreen, 0*u,  0*u, 1*u, 32),
    FS_CROSS_G_MARKER_MIDDLE = ImageData(fsCrossGreen, 0*u,   32, 1*u, u-64),
    FS_CROSS_G_MARKER_START  = ImageData(fsCrossGreen, 0*u, u-32, 1*u, 32),
    FS_CROSS_B_MARKER_END    = ImageData(fsCrossBlue , 0*u,  0*u, 1*u, 32),
    FS_CROSS_B_MARKER_MIDDLE = ImageData(fsCrossBlue , 0*u,   32, 1*u, u-64),
    FS_CROSS_B_MARKER_START  = ImageData(fsCrossBlue , 0*u, u-32, 1*u, 32),

    --markers
    BEAT_LEFT    = ImageData(beatMarker,   0 , 0, 64, 64),
    BEAT_RIGHT   = ImageData(beatMarker,   64, 0, 64, 64),
    REWIND_LEFT  = ImageData(rewindMarker, 0 , 0, 64, 64),
    REWIND_RIGHT = ImageData(rewindMarker, 64, 0, 64, 64),

    --freestyle samples
    FS_SAMPLE_END    = ImageData(fsSampleRed, 0*u, 0*u, u, u/2),
    FS_SAMPLE_MIDDLE = ImageData(fsSampleRed, 0*u, 1*u, u, u),
    FS_SAMPLE_START  = ImageData(fsSampleRed, 0*u, 2.5*u, u, u/2)
}

