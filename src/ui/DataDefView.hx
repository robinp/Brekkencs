package ui;

import haxe.ui.containers.HBox;

import rts.DataDefs;

@:xml('
<hbox>
    <label id="dname" text="" />
    <label id="dfields" text="" />
</hbox>
')
class DataDefView extends HBox {
    public var d(default, null): DataDef;

    public function new(d: DataDef) {
        super();
        setDataDef(d);
    }

    public function setDataDef(d: DataDef) {
        this.d = d;
        dname.text = d.name;
        var ks = [];
        for (k in d.fields.keys()) {
          ks.push(k);
        }
        dfields.text = ks.join(", ");
    }
}
