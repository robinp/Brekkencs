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

// Use of this points to some smell in the logic.
// Acceptable temporarily, but bear in mind.
var kArbitraryExpr = ELit(LNum(0));

class Env {

    private var dataDefs: DataDefs = emptyDataDefs();

    private var entityFields: Map<TypeName, Map<Int, Map<String, Float>>> = [];

    // Poor man's set.
    private var entities: Map<Int, Bool> = [];

    public function new() {
        entityFields["Baz"] = [7 => ["c" => 0.5]];
        entities[7] = true;
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
            case EBindQuery(n, ke):
                // For now mutate the nameEnv. We might want an immutabel version
                // later? Or only while in interactive/debug mode?
                var prev = nameEnv[n.name];
                // Let's query the entities, and bind each in succession to the name
                // while executing the inner expression.
                var res = kArbitraryExpr;
                for (eid in entities.keys()) {
                    nameEnv[n.name] = NEntity(eid);
                    res = interpret(nameEnv, ke);
                }
                nameEnv[n.name] = prev;  // TODO delete if was missing etc
                // Hack: this is kind of arbitrary and useless.
                // Should we support some kind of reducer over the produced results?
                // Might be more meaningful. Let's see if the need emerges
                // (but reducing can be emulated via using a local var etc.. let's
                // see when we have funcalls. So supporting at AST level, unless
                // some good reason, seems a bit overblown?)
                res;
            case EQueryCtrl(c, ke):
                switch c {
                    case QFilter(ce):
                        // Note: should we enforce purit of control expressions?
                        // Does it help with guarantees around entity iteration/caching?
                        // If it would make entity query cumbersome to take side-effects
                        // into account, then sure we should enforce. Let's see.
                        // (Or, from other perspective, why would it be ever useful to have effects here?)
                        var res = interpret(nameEnv, ce);
                        switch res {
                            case ELit(LBool(v)):
                                if (v) interpret(nameEnv, ke)
                                else kArbitraryExpr;
                            case _: throw new haxe.Exception("Query filter should eval to Bool, not " + res);
                        }
                }
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
