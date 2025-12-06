--Because lua doesn't have structs, this is the closest thing to have uniform tables 
function ImageData(source, x, y, w, h)
    return {
        src = source,
        srcx = x,
        srcy = y,
        srcw = w,
        srch = h
    }
end
