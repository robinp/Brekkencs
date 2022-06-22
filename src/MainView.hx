import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
    public function new() {
        super();
        button1.onClick = function(e) {
            button1.text = "No Thanks!";
        }
        addComponent(new my.Compy());
    }

    @:bind(button2, MouseEvent.CLICK)
    private function onMyButton(e:MouseEvent) {
        button2.text = "Thanks!";
    }
}
