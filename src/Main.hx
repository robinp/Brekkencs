import haxe.ui.core.Screen;
import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;

import ui.DataDefView;
import ui.DataDefList;

import rts.DataDefs;
import rts.Env;
import rts.heaps.HeapsGfx;
import ast.Expr;
import ast.Sample;
import parse.Parser;

class Main extends hxd.App {
    static function main() {
      new Main();
    }

    private var step: Int = 0;
    private var env: Env;
    private var exps: Array<Expr<ast.Context>>;

    override function init() {
        var tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        tf.text = "Hello World !";

        var hgfx = new HeapsGfx(s2d);
        env = new Env(hgfx);
        var d = new DataDef("Foobar", ["a" => true, "b" => true]);
        var d2 = new DataDef("Baz", ["c" => true]);
        env.addDataDef(d);
        env.addDataDef(d2);
        var dv = new DataDefView(d);
        var dv2 = new DataDefView(d2);
        var ds = new DataDefList();
        ds.addDataDefView(dv);
        ds.addDataDefView(dv2);
        //app.addComponent(ds);

        trace(env);
        trace(d);
        trace(s1());
        trace("resources:" + haxe.Resource.listNames());
        var s2 = haxe.Resource.getString("R_s2_bk");
        trace("Going to parse: [" + s2 + "]");
        var p = new Parser(s2);
        exps = p.parseMany();
        for (e in exps) {
          trace("parsed [" + e + "]");
        }

        trace("Env setup");
        // Just a dummy entity, so dummy query can work.
        // Well, could just allow query-less must-s.
        env.interpret([], p.parseFullyFrom("(new e t)"));

        trace("Loop starts");
    }

    override function update(dt:Float) {
        for (e in exps) {
          env.interpret(["delta" => LNum(dt), "step" => LNum(step)], e);
        }
        if (step++ % 100 == 0) {
          trace("Step ", step, "Delta ", dt, "Entity count: ", env.entityCount());
        }
    }
}
