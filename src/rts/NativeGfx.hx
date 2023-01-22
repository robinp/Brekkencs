package rts;

import rts.DataDefs;

interface NativeGfx {
    function clear(): Void;
    function draw(x: Float, y: Float): Void;
}
