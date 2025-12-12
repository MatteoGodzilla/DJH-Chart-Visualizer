require ("ImageData")

local function getScriptDir()
    local _, filename = reaper.get_action_context()
    --regex to remove the last part of the filename, which contains images.lua
    --basic idea: capture all chars before the / 
    --since matching is greedy, it gets up until the last directory
    return filename:match("(.*[/\\])")
end

local baseDir = getScriptDir() .. "images/"
local tapsImage       = gfx.loadimg(0, baseDir.."taps.png") 
local zonesImage      = gfx.loadimg(1, baseDir.."zones.png") 
local crossImage      = gfx.loadimg(2, baseDir.."cross.png")
local laneImage       = gfx.loadimg(3, baseDir.."lanes.png")
local transitionImage = gfx.loadimg(3, baseDir.."laneTransitions.png")
local greenSpikes     = gfx.loadimg(4, baseDir.."greenSpikes.png")
local blueSpikes      = gfx.loadimg(5, baseDir.."blueSpikes.png")

--TODO: hold tap trail
--TODO: crossfade lanes
--TODO: crossfade spikes
--TODO: freestyle
return {
    TAP_G_L0 = ImageData(tapsImage,0   ,0,512,512), 
    TAP_G_L1 = ImageData(tapsImage,512 ,0,512,512), 
    TAP_G_L2 = ImageData(tapsImage,1024,0,512,512), 
    TAP_G_L3 = ImageData(tapsImage,1536,0,512,512), 

    TAP_R_L0 = ImageData(tapsImage,0   ,512,512,512), 
    TAP_R_L1 = ImageData(tapsImage,512 ,512,512,512), 
    TAP_R_L2 = ImageData(tapsImage,1024,512,512,512), 
    TAP_R_L3 = ImageData(tapsImage,1536,512,512,512), 

    TAP_B_L0 = ImageData(tapsImage,0   ,1024,512,512), 
    TAP_B_L1 = ImageData(tapsImage,512 ,1024,512,512), 
    TAP_B_L2 = ImageData(tapsImage,1024,1024,512,512), 
    TAP_B_L3 = ImageData(tapsImage,1536,1024,512,512), 

    ZONE_G    = ImageData(zonesImage,0   ,0  ,512 ,512),
    ZONE_R    = ImageData(zonesImage,512 ,0  ,512 ,512),
    ZONE_B    = ImageData(zonesImage,1024,0  ,512 ,512),
    ZONE_SLOT = ImageData(zonesImage,0   ,512,1024,512),

    --lane textures
    --for when no events are changing the sides
    LANE_G_ACTIVE   = ImageData(laneImage,0   ,0,512,512), --vertical stretch
    LANE_G_EFFECTS  = ImageData(laneImage,512 ,0,512,512), --vertical stretch
    LANE_G_INACTIVE = ImageData(laneImage,1024,0,512,512), --vertical stretch
    
    LANE_R_ACTIVE   = ImageData(laneImage,0   ,512,512,512), --vertical stretch
    LANE_R_EFFECTS  = ImageData(laneImage,512 ,512,512,512), --vertical stretch
    LANE_R_INACTIVE = ImageData(laneImage,1024,512,512,512), --vertical stretch

    LANE_B_ACTIVE   = ImageData(laneImage,0   ,1024,512,512), --vertical stretch
    LANE_B_EFFECTS  = ImageData(laneImage,512 ,1024,512,512), --vertical stretch
    LANE_B_INACTIVE = ImageData(laneImage,1024,1024,512,512), --vertical stretch

    --transitions from a lane state to another
    LANE_G_ACTIVE_EFFECTS = ImageData(), 
    LANE_G_ACTIVE_INACTIVE = ImageData(), 
    LANE_G_EFFECTS_ACTIVE = ImageData(),
    LANE_G_EFFECTS_INACTIVE = ImageData(),
    LANE_G_INACTIVE_ACTIVE = ImageData(),
    LANE_G_INACTIVE_EFFECTS = ImageData(),

    LANE_R_ACTIVE_EFFECTS = ImageData(),
    LANE_R_ACTIVE_INACTIVE = ImageData(),
    LANE_R_EFFECTS_ACTIVE = ImageData(),
    LANE_R_EFFECTS_INACTIVE = ImageData(),
    LANE_R_INACTIVE_ACTIVE = ImageData(),
    LANE_R_INACTIVE_EFFECTS = ImageData(),

    LANE_B_ACTIVE_EFFECTS = ImageData(),
    LANE_B_ACTIVE_INACTIVE = ImageData(),
    LANE_B_EFFECTS_ACTIVE = ImageData(),
    LANE_B_EFFECTS_INACTIVE = ImageData(),
    LANE_B_INACTIVE_ACTIVE = ImageData(),
    LANE_B_INACTIVE_EFFECTS = ImageData(),

    --Front: part that is earlier in time (visually at the bottom of the window)
    --Imagine you are in the zones and the note is facing you

    --crossfade for left side
    CROSS_G_BACK_LEFT_ACTIVE = ImageData(),
    CROSS_G_BACK_LEFT_EFFECTS = ImageData(),
    --CROSS_G_BACK_LEFT_INACTIVE = ImageData(), -- does not make sense
    CROSS_G_BACK_RIGHT_ACTIVE = ImageData(),
    CROSS_G_BACK_RIGHT_EFFECTS = ImageData(),
    CROSS_G_BACK_RIGHT_INACTIVE = ImageData(),
    CROSS_G_FRONT_LEFT_ACTIVE = ImageData(),
    CROSS_G_FRONT_LEFT_EFFECTS = ImageData(),
    --CROSS_G_FRONT_LEFT_INACTIVE = ImageData(), -- does not make sense
    CROSS_G_FRONT_RIGHT_ACTIVE = ImageData(),
    CROSS_G_FRONT_RIGHT_EFFECTS = ImageData(),
    CROSS_G_FRONT_RIGHT_INACTIVE = ImageData(),

    --crossfade for right side
    CROSS_B_BACK_LEFT_ACTIVE = ImageData(),
    CROSS_B_BACK_LEFT_EFFECTS = ImageData(),
    CROSS_B_BACK_LEFT_INACTIVE = ImageData(),
    CROSS_B_BACK_RIGHT_ACTIVE = ImageData(),
    CROSS_B_BACK_RIGHT_EFFECTS = ImageData(),
    --CROSS_B_BACK_RIGHT_INACTIVE = ImageData(), --does not make sense
    CROSS_B_FRONT_LEFT_ACTIVE = ImageData(),
    CROSS_B_FRONT_LEFT_EFFECTS = ImageData(),
    CROSS_B_FRONT_LEFT_INACTIVE = ImageData(),
    CROSS_B_FRONT_RIGHT_ACTIVE = ImageData(),
    CROSS_B_FRONT_RIGHT_EFFECTS = ImageData(),
    --CROSS_B_FRONT_RIGHT_INACTIVE = ImageData(), --does not make sense
   
    --spikes for the left side
    SPIKE_G_BACK_LEFT_ACTIVE     = ImageData(greenSpikes,0   ,0  ,1024,256),
    SPIKE_G_BACK_LEFT_EFFECTS    = ImageData(greenSpikes,1024,0  ,1024,256),
    SPIKE_G_BACK_LEFT_INACTIVE   = ImageData(greenSpikes,2048,0  ,1024,256),
    SPIKE_G_BACK_RIGHT_ACTIVE    = ImageData(greenSpikes,3072,0  ,1024,256),
    SPIKE_G_BACK_RIGHT_EFFECTS   = ImageData(greenSpikes,4098,0  ,1024,256),
    SPIKE_G_BACK_RIGHT_INACTIVE  = ImageData(greenSpikes,5120,0  ,1024,256),
    SPIKE_G_FRONT_LEFT_ACTIVE    = ImageData(greenSpikes,0   ,256,1024,256),
    SPIKE_G_FRONT_LEFT_EFFECTS   = ImageData(greenSpikes,1024,256,1024,256),
    SPIKE_G_FRONT_LEFT_INACTIVE  = ImageData(greenSpikes,2048,256,1024,256),
    SPIKE_G_FRONT_RIGHT_ACTIVE   = ImageData(greenSpikes,3072,256,1024,256),
    SPIKE_G_FRONT_RIGHT_EFFECTS  = ImageData(greenSpikes,4098,256,1024,256),
    SPIKE_G_FRONT_RIGHT_INACTIVE = ImageData(greenSpikes,5120,256,1024,256),

    --spikes for the right side
    SPIKE_B_BACK_LEFT_ACTIVE     = ImageData(blueSpikes,0   ,0  ,1024,256),
    SPIKE_B_BACK_LEFT_EFFECTS    = ImageData(blueSpikes,1024,0  ,1024,256),
    SPIKE_B_BACK_LEFT_INACTIVE   = ImageData(blueSpikes,2048,0  ,1024,256),
    SPIKE_B_BACK_RIGHT_ACTIVE    = ImageData(blueSpikes,3072,0  ,1024,256),
    SPIKE_B_BACK_RIGHT_EFFECTS   = ImageData(blueSpikes,4098,0  ,1024,256),
    SPIKE_B_BACK_RIGHT_INACTIVE  = ImageData(blueSpikes,5120,0  ,1024,256),
    SPIKE_B_FRONT_LEFT_ACTIVE    = ImageData(blueSpikes,0   ,256,1024,256),
    SPIKE_B_FRONT_LEFT_EFFECTS   = ImageData(blueSpikes,1024,256,1024,256),
    SPIKE_B_FRONT_LEFT_INACTIVE  = ImageData(blueSpikes,2048,256,1024,256),
    SPIKE_B_FRONT_RIGHT_ACTIVE   = ImageData(blueSpikes,3072,256,1024,256),
    SPIKE_B_FRONT_RIGHT_EFFECTS  = ImageData(blueSpikes,4098,256,1024,256),
    SPIKE_B_FRONT_RIGHT_INACTIVE = ImageData(blueSpikes,5120,256,1024,256),
}

