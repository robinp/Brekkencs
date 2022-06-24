package my;

import haxe.ui.containers.HBox;
import haxe.ui.events.MouseEvent;

@:xml('
<hbox>
    <textfield id="textfield" text="0" />
    <button id="deinc" text="--" />
    <button id="inc" text="++" />
</hbox>
')
class Compy extends HBox {
    public var wat: String = "?";

    public function new() {
        super();
    }

    @:bind(inc, MouseEvent.CLICK)
    private function ping(e) {
        trace(wat);
    }
    // PROPS
    //@:bind(new_task.visible)
    //public var adding:Bool = true;
}
