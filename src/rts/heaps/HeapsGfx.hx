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

    public function draw(x: Float, y: Float): Void {
        //trace("Going to draw at ", x, y);
        gfx.setColor(0xFF0044);
        gfx.beginFill(0x804FDD);
        gfx.drawCircle(x, y, 3.0);
        gfx.endFill();
    }
}
