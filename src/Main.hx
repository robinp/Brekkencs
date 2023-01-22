import rts.DataDefs;
import rts.Env;
import rts.heaps.HeapsGfx;
import ast.Expr;
import parse.Parser;

class Main extends hxd.App {
    static function main() {
      hxd.Res.initEmbed();
      new Main();
    }

    private var gfx: rts.NativeGfx;
    private var env: Env;

    private var step: Int = 0;
    private var exps: Array<Expr<ast.Context>>;

    private var sysMouseUpdate: Expr<ast.Context>;

    private function reset() {
      gfx.clear();
      step = 0;

      trace("Env setup");
      env = new Env(gfx);
      var d = new DataDef("Foobar", ["a" => true, "b" => true]);
      var d2 = new DataDef("Baz", ["c" => true]);
      env.addDataDef(d);
      env.addDataDef(d2);

      // TODO check if mouse entity was deleted and push it back in each
      //   step... once we have deletion.
      var p = new Parser("");
      var sysMouseInit = p.parseFullyFrom("(new e (set e.Mouse.x 0 (set e.Mouse.y 0 (set e.Mouse.pressed 0 (set e.Mouse.dummy 1 t)))))");
      env.interpretSystem([], sysMouseInit);

      // TODO some constraint that entity has given comp.
      sysMouseUpdate = p.parseFullyFrom("(query e (must (> e.Mouse.dummy 0) (set e.Mouse.x mx (set e.Mouse.y my t))))");
    }

    private function parseCode(s: String) {
        trace("Going to parse: [" + s + "]");
        var p = new Parser(s);
        try {
          exps = p.parseMany();
          for (e in exps) {
            trace("parsed [" + e + "]");
          }
        } catch (e) {
            trace("Exception parsing", e);
        }
    }

    override function init() {
        var tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        tf.text = "Hello World !";

        /* Not bad, but multi-line edit needs some tweaks.
        var inp = new h2d.TextInput(hxd.res.DefaultFont.get(), s2d);
        inp.text = "Edit\nme";
        inp.x = 5;
        inp.y = 100;
        inp.textColor = 0xAAAAAA;
        */

        gfx = new HeapsGfx(s2d);
        trace("resources:" + haxe.Resource.listNames());
        var s2 = haxe.Resource.getString("R_s2_bk");

        #if js
        js.Syntax.code("window.setSource({0});", s2);
        js.Syntax.code("window.setUpdateCallback({0});", parseCode);
        js.Syntax.code("window.setResetCallback({0});", reset);
        #end

        reset();
        parseCode(s2);

        trace("Loop starts");
    }

    override function update(dt:Float) {
        // Input updates
        env.interpretSystem(["mx" => LNum(s2d.mouseX), "my" => LNum(s2d.mouseY)], sysMouseUpdate);
        // Logic
        for (e in exps) {
          env.interpretSystem(["delta" => LNum(dt), "step" => LNum(step)], e);
        }
        // Output and other effects
        env.draw();
        // Some debug
        if (step++ % 100 == 0) {
          trace("Step ", step, "Delta ", dt, "Entity count: ", env.entityCount());
        }
    }
}
