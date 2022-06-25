package rts;

import rts.DataDefs;
import ast.Expr;

enum Named {
    NEntity(eid: Int);
    NLit(l: Lit);
}

function getNamedEid(ne: Map<String, Named>, n: String): Int {
    return switch (ne[n]) {
        case NEntity(eid): eid;
        case NLit(_): throw new haxe.Exception("not an entitiy ref: " + n);
    }
}

class Env {

    private var dataDefs: DataDefs = emptyDataDefs();

    private var entityFields: Map<TypeName, Map<Int, Map<String, Float>>> = new Map();

    public function new() {
        entityFields["Baz"] = [7 => ["c" => 0.5]];
    }

    public function addDataDef(d: DataDef) {
        dataDefs[d.name] = d;
    }

    public function interpret(nameEnv: Map<String, Named>, e: Expr) {
        // Note: top-level interpret is mostly called for its side-effects.
        // But we could wrap the return type to be more indicative instead
        // of coercing to Lit.
        return switch (e) {
            case ELit(lit): lit;
            case ERef(r):
            switch(r) {
            case REntField(en, cn, fn):
                var eid = getNamedEid(nameEnv, en.name);
                var n = entityFields[cn.name][eid][fn.name];
                LNum(n);
            case _: LNum(42);
            }
            case _: LNum(4200);
        }
    }
}
