package rts;

import rts.DataDefs;

interface NativeGfx {
    function draw(comps: Map<TypeName, Map<String, Float>>): Void;
}
