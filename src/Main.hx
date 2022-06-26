import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;

import ui.DataDefView;
import ui.DataDefList;

import rts.DataDefs;
import rts.Env;
import ast.Expr;
import ast.Sample;

class Main {
    static public function main():Void {
        trace("Hello World");
        var env = new Env();
        var d = new DataDef("Foobar", ["a" => true, "b" => true]);
        var d2 = new DataDef("Baz", ["c" => true]);
        env.addDataDef(d);
        trace(env);
        trace(d);
        trace(s1());
        var r = REntField(mkName("a"), mkName("Baz"), mkName("c"));
        trace(env.interpret(
            ["a" => NEntity(7)],
            EEffect(
              FSet(r,
                            EBinop(BAdd,
                            ERef(r),
                            ELit(LNum(2.7)))
                            ),
              ERef(r))));

        Toolkit.init();
        var app = new HaxeUIApp();
        app.ready(function() {
            app.addComponent(new MainView());
            var dv = new DataDefView(d);
            var dv2 = new DataDefView(d2);
            var ds = new DataDefList();
            ds.addDataDefView(dv);
            ds.addDataDefView(dv2);
            app.addComponent(ds);
            app.start();
        });
    }
}
