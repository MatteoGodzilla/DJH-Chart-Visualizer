# DJH-Chart-Visualizer
This is a Reaper plugin that visually renders DJ Hero 2 custom tracks inside Reaper.

## How to use
Instructions updated as of Reaper v7.47
- Download this project by either cloning or downloading as zip to a known location
    - in the case of zip, extract the files so `main.lua` is directly accessible
- In Reaper:
    - Go to `Actions` -> `Show action list...` -> `ReaScript: Run ReaScript (EEL2 or Lua)...` (pro tip: use the filter bar on the top left)
    - Navigate to where you have downloaded the project and select `main.lua`
    - Click `Open` 
- Profit

Once you have opened the visualizer once, you can also open it with `Actions` -> `Show action list...` -> `ReaScript: Run last ReaScript (EEL2 or Lua)`, skipping a step.

## Shortcuts
- `Minus Key`: Reduce zoom
- `Equals Key`: Increase zoom 
- `Left Arrow`: Switch to previous track (if multiple are present)
- `Right Arrow`: Switch to next track (if multiple are present)

## Sample map file
In your reaper project, next to the .rpp file you can put a simple text file called `sampleMap.txt`.
This file is used to give more information to the visualizer that is not represented in the midi itself.
This text file has the following format: 
```
green = <list of velocities, separated by space>
blue = <list of velocities, separated by space>
```

Example:
```
green = 0 1 2
blue = 4 5 6 7
```

Note: this file is loaded when first opening the visualizer, so if the contents change you have to re-open the visualizer
