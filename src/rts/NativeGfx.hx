package rts;

import rts.DataDefs;

interface NativeGfx {
    function clear(): Void;
    function draw(comps: Map<TypeName, Map<String, Float>>): Void;
}
