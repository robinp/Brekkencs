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

/*
class Main extends hxd.App {
    override function init() {
        var tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
        tf.text = "Hello World !";
*/

class Main {
    static function main():Void {
        Toolkit.init();
        var app = new HaxeUIApp();

        trace("Hello World");

        app.ready(function() {
            //app.addComponent(new MainView());

            trace("Foo");
            var hgfx = new HeapsGfx(cast(Screen.instance.root, h2d.Scene));
            var env = new Env(hgfx);
            var d = new DataDef("Foobar", ["a" => true, "b" => true]);
            var d2 = new DataDef("Baz", ["c" => true]);
            env.addDataDef(d);
            var dv = new DataDefView(d);
            var dv2 = new DataDefView(d2);
            var ds = new DataDefList();
            ds.addDataDefView(dv);
            ds.addDataDefView(dv2);
            //app.addComponent(ds);

            trace(env);
            trace(d);
            trace(s1());
            var r = REntField(mkName("a"), mkName("Baz"), mkName("c"));
            trace(env.interpret(
                ["a" => LEntity(7)],
                EEffect(
                FSet(r,
                                EBinop(BAdd,
                                ERef(r),
                                ELit(LNum(2.7)))
                                ),
                ERef(r))));

            trace("resources:" + haxe.Resource.listNames());
            var s2 = haxe.Resource.getString("R_s2_bk");
            trace("Going to parse: [" + s2 + "]");
            var p = new Parser(s2);
            var exps = p.parseMany();
            for (e in exps) {
              trace("parsed [" + e + "]");
            }
            trace("Loop starts");
            var step = 0;
            var t0 = Sys.time();
            var dt = 0.005;  // Arbitrary small initial value.
            new haxe.ui.util.Timer(0, function() {
                for (e in exps) {
                  env.interpret(["delta" => LNum(dt), "step" => LNum(step)], e);
                }

                // Account time spent.
                var t1 = Sys.time();
                if (step++ % 100 == 0) {
                  trace("Step ", step, "Delta ", t1-t0, "Entity count: ", env.entityCount()-100);
                }
                dt = t1 - t0;
                t0 = t1;
            });
            trace("Done");

            trace("App starts?");
            app.start();
        });
        trace("Bye world");
    }
}
