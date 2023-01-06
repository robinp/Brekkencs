package rts.heaps;

import rts.DataDefs;
import rts.NativeGfx;

class HeapsGfx implements NativeGfx {
    private var s2d: h2d.Scene;
    private var gfx: h2d.Graphics;

    public function new(s2d: h2d.Scene) {
        this.s2d = s2d;
        gfx = new h2d.Graphics(s2d);
        gfx.setColor(0xFF0044);
        trace("S2D dims", s2d.width, s2d.height);
    }

    public function clear(): Void {
      gfx.clear();
    }

    public function draw(comps: Map<TypeName, Map<String, Float>>): Void {
        // Check things
        // Option to indicate error on return? Or should communicate that on
        // a side-channel with RTS / env? Depends if it is any useful for the
        // AST / interpreter to know about the error on the spot. Probably
        // not immediately useful.
        var p = comps["Pos"];
        var x = p["x"];
        var y = p["y"];
        //trace("Going to draw at ", x, y);
        gfx.setColor(0xFF0044);
        gfx.beginFill(0x804FDD);
        gfx.drawCircle(x, y, 3.0);
        gfx.endFill();
    }
}
