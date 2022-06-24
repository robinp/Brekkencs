import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;

import rts.DataDefs;

class Main {
    static public function main():Void {
        Toolkit.init();
        var app = new HaxeUIApp();
        app.ready(function() {
            app.addComponent(new MainView());
            app.start();
        });
        trace("Hello World");
        var dd: DataDefs = new Map();
        trace(dd);
    }
}
