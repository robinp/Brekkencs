import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;

class Main {
    static public function main():Void {
        Toolkit.init();
        var app = new HaxeUIApp();
        app.ready(function() {
          app.addComponent(new MainView());
          app.start();
        });
        trace("Hello World");
    }
}
