require ("ImageData")

local function getScriptDir()
    local _, filename = reaper.get_action_context()
    --regex to remove the last part of the filename, which contains images.lua
    --basic idea: capture all chars before the / 
    --since matching is greedy, it gets up until the last directory
    return filename:match("(.*[/\\])")
end

local baseDir = getScriptDir() .. "images/"
local tapsImage = gfx.loadimg(0,baseDir.."taps.png") 
local zonesImage = gfx.loadimg(1,baseDir.."zones.png") 

--TODO: hold tap trail
--TODO: crossfade lanes
--TODO: crossfade spikes
--TODO: freestyle
return {
    TAP_G_L0 = ImageData(tapsImage, 0, 0, 512, 512), 
    TAP_G_L1 = ImageData(tapsImage, 512, 0, 512, 512), 
    TAP_G_L2 = ImageData(tapsImage, 1024, 0, 512, 512), 
    TAP_G_L3 = ImageData(tapsImage, 1536, 0, 512, 512), 

    TAP_R_L0 = ImageData(tapsImage, 0, 512, 512, 512), 
    TAP_R_L1 = ImageData(tapsImage, 512, 512, 512, 512), 
    TAP_R_L2 = ImageData(tapsImage, 1024, 512, 512, 512), 
    TAP_R_L3 = ImageData(tapsImage, 1536, 512, 512, 512), 

    TAP_B_L0 = ImageData(tapsImage, 0, 1024, 512, 512), 
    TAP_B_L1 = ImageData(tapsImage, 512, 1024, 512, 512), 
    TAP_B_L2 = ImageData(tapsImage, 1024, 1024, 512, 512), 
    TAP_B_L3 = ImageData(tapsImage, 1536, 1024, 512, 512), 

    ZONE_G = ImageData(zonesImage, 0, 0, 512, 512);
    ZONE_R = ImageData(zonesImage, 512, 0, 512, 512);
    ZONE_B = ImageData(zonesImage, 1024, 0, 512, 512);
    ZONE_SLOT = ImageData(zonesImage, 0, 512, 1024, 512);
}

