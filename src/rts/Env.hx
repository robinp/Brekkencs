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

    public function interpret(nameEnv: Map<String, Named>, e: Expr): Expr {
        return switch (e) {
            case ELit(_): e;
            case ERef(r):
                switch(r) {
                case REntField(en, cn, fn):
                    // TODO indicate errors
                    var eid = getNamedEid(nameEnv, en.name);
                    var n = entityFields[cn.name][eid][fn.name];
                    // Lit vs Const in AST?
                    // Is this a hack that we are interpreting the parsed AST directly?
                    ELit(LNum(n));
                case REntComp(_, _):
                    throw new haxe.Exception("Can't eval Comp ref (yet?)");
                }
            case EBinop(op, e1, e2):
                var ei1 = interpret(nameEnv, e1);
                var ei2 = interpret(nameEnv, e2);
                switch [ei1, ei2] {
                case [ELit(LNum(n1)), ELit(LNum(n2))]:
                    switch op {
                    case BAdd: ELit(LNum(n1 + n2));
                    case _: throw new haxe.Exception("Unimplemented binop" + op);
                    }
                case [ELit(LBool(b1)), ELit(LBool(b2))]:
                    switch op {
                    case BEq: ELit(LBool(b1 == b2));
                    case _: throw new haxe.Exception("Unimplemented binop" + op);
                    }
                case _: throw new haxe.Exception("Can't mix operand types in expr");
                }
            case EEffect(f, ke):
                switch f {
                case FSet(r, e):
                    var ei = interpret(nameEnv, e);
                    switch r {
                    case REntField(en, cn, fn):
                        var eid = getNamedEid(nameEnv, en.name);
                        entityFields[cn.name][eid][fn.name] = assertAsNum(ei);
                    case REntComp(_, _):
                        throw new haxe.Exception("Setting component on entity is not yet implemented");
                    }
                }
                interpret(nameEnv, ke);
            case e: throw new haxe.Exception("Unimplemented expression: " + e);
        }
    }
}

function assertAsNum(e: Expr): Float {
    return switch e {
        case ELit(LNum(n)): n;
        case _: throw new haxe.Exception("Expected number, got: " + e);
    };
}
