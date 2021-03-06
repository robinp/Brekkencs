package rts;

import rts.DataDefs;
import rts.NativeGfx;
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
var kArbitraryExpr = ELit(LNum(42001));

class CutToQueryException extends haxe.Exception {
    public function new() {
        super("cut");
    }
}

class Env {

    private var dataDefs: DataDefs = emptyDataDefs();

    // The leaf field map should refer to the same instance.
    private var compEntityFields: Map<TypeName, Map<Int, Map<String, Float>>> = [];
    private var entityCompFields: Map<Int, Map<TypeName, Map<String, Float>>> = [];

    private var nativeGfx: NativeGfx;

    public function new(ngfx: NativeGfx) {
        this.nativeGfx = ngfx;
        // Move below out to Main or something.
        var fBaz = ["c" => 0.5];
        var fPos = ["x" => 70.0, "y" => 50.0];
        compEntityFields["Baz"] = [7 => fBaz];
        compEntityFields["Pos"] = [7 => fPos];
        entityCompFields[7] = [
            "Baz" => fBaz,
            "Pos" => fPos,
        ];
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
                    // TODO indicate errors.. or eventually should have some
                    // error-continuation mechanism? Would need to write stuff
                    // in CPS style? Worth the hassle?
                    // (If we are properly immutable, could just restart the
                    // whole thing from some more granular checkpoint, saving
                    // most of the CPS hassle..)
                    // E: name missing
                    var eid = getNamedEid(nameEnv, en.name);
                    var ctab = compEntityFields[cn.name];
                    if (ctab == null) throw new haxe.Exception("Unknown component: " + cn.name);
                    var eComp = ctab[eid];
                    if (eComp == null) {
                        // Why not just throw specific exception and catch, instead
                        // of having to plumb this through? Good question.
                        throw new CutToQueryException();
                    } else {
                        var n = eComp[fn.name];
                        // Unrelated wondering: Lit vs Const in AST?
                        //   Is this a hack that we are interpreting the parsed AST directly?

                        // For now we only have numeric fields.
                        ELit(LNum(n));
                    }
                case REntComp(_, _):
                    throw new haxe.Exception("Can't eval Comp ref (yet?)");
                case REntOrLocal(_):
                    // Can't further eval a local ref, can we?
                    return e;
                }
            case EBinop(op, e1, e2):
                var ei1 = interpret(nameEnv, e1);
                var ei2 = interpret(nameEnv, e2);
                switch [ei1, ei2] {
                case [ELit(LNum(n1)), ELit(LNum(n2))]:
                    switch op {
                    case BAdd: ELit(LNum(n1 + n2));
                    case BLt: ELit(LBool(n1 < n2));
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
                        // TODO error handlings
                        // E: missing name
                        var eid = getNamedEid(nameEnv, en.name);
                        // E: component doesn't exist?
                        //   Should we eventually auto-create (with field defaulting)?
                        compEntityFields[cn.name][eid][fn.name] = assertAsNum(ei);
                    case REntComp(_, _):
                        throw new haxe.Exception("Setting component on entity is not yet implemented");
                    case REntOrLocal(_):
                        throw new haxe.Exception("Setting local/ent is not a valid effect");
                    }
                case FNative(nc):
                    switch nc {
                    case NDraw(e):
                        var ei = interpret(nameEnv, e);
                        switch ei {
                        case ERef(REntOrLocal(en)):
                            // E: missing name
                            // E: not an entity ref
                            var eid = getNamedEid(nameEnv, en.name);
                            nativeGfx.draw(entityCompFields.get(eid));
                        case _: throw new haxe.Exception("Need entity ref for !draw, got: " + ei);
                        }
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
                for (eid in entityCompFields.keys()) {
                    nameEnv[n.name] = NEntity(eid);
                    try {
                        res = interpret(nameEnv, ke);
                    } catch (e: CutToQueryException) {
                        // TODO should somehow keep track which query we should
                        // cut back to. Cutting to the nearest might not be
                        // the correct thing (although... code should be
                        // rearrangable so cutting to nearest is the right thing.
                        // Maybe we should rewrite the AST, or at least its runtime,
                        // or just suggest to the editor to move it to the right
                        // place).

                        // pass
                    }
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
                                else throw new CutToQueryException();
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
