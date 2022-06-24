package ui;

import haxe.ui.containers.ScrollView;

import ui.DataDefView;

// See https://github.com/haxeui/haxeui-core/issues/464 if this could be done better?
@:xml('
<scrollview>
  <vbox id="box">
  </vbox>
</scrollview>
')
class DataDefList extends ScrollView {
    public function new() {
        super();
    }

    public function addDataDefView(d: DataDefView) {
        box.addComponent(d);
        d.onClick = function(_) {
          trace("clicked", d.d.name);
        }
    }
}
