--Constants
UNIT = 80 --pixels, same for horizontal and vertical
ORIGIN_X = 0
ORIGIN_Y = 0

TRANSITION = UNIT / 4
PADDING = UNIT / 10
EFFECTS_HANDLE_HEIGHT = UNIT / 3

function updateOrigin(newWidth, newHeight)
    ORIGIN_X = newWidth / 2
    ORIGIN_Y = newHeight - UNIT
end
