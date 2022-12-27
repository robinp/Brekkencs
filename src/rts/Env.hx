package rts;

import rts.DataDefs;
import rts.NativeGfx;
import ast.Expr;
import ast.Context;

function lookupNamedEidFromEnv(ne: Map<String, Lit>, n: String): Int {
    return switch (ne[n]) {
        case LEntity(eid): eid;
        case e: throw new haxe.Exception("not an entitiy ref for '" + n + "', value is '" + e + "'");
    }
}

// Use of this points to some smell in the logic.
// Acceptable temporarily, but bear in mind.
var kArbitraryExpr = ELit(LNum(42001));

/**
 * Signals that a query-bound entity didn't fulfil some expectations, so
 * we should instead skip to the next entity.
 *
 * Ideally we analyse the subprogram using the query result, and automatically
 * determine what kind of entities to query for - most likely in terms of the
 * components the entity has, but other dimensions are possible too.
 *
 * Instead of that, we now just iterate all entities when querying, and break
 * execution late, when we find a missing component. Note though, that this
 * mechanism might be needed even later, if it is not possible to build an
 * exact index for the kind of entities used: a subprogram might contain
 * branches where it accesses different components, so the set of entities
 * would be ambiguous anyway (though we don't have the semantics exactly
 * hashed out, what it would mean to access different components on different
 * branches).
 */
class CutToQueryException extends haxe.Exception {
    public function new() {
        super("cut");
    }
}

typedef EntitiesFields = Map<Int, Map<String, Float>>;

class Env {

    private var dataDefs: DataDefs = emptyDataDefs();

    private var autoRegisterComponents: Bool = true;

    // The leaf field map should refer to the same map instance.
    private var compEntityFields: Map<TypeName, EntitiesFields> = [];
    private var entityCompFields: Map<Int, Map<TypeName, Map<String, Float>>> = [];
    private var nextEntityId: Int = 0;

    // Provides drawing capability on the specific platform.
    private var nativeGfx: NativeGfx;

    public function new(ngfx: NativeGfx) {
        this.nativeGfx = ngfx;
    }

    // To some generic stats later as needed.
    public function entityCount(): Int {
      return nextEntityId;
    }

    public function addEntity(): Int {
      // Overflow not handled...
      var eid = nextEntityId++;
      entityCompFields[eid] = new Map();
      return eid;
    }

    public function addDataDef(d: DataDef) {
        dataDefs[d.name] = d;
        compEntityFields[d.name] = new Map();
    }

    inline private function ensureComponentAndGetEntitiesFields(c: String): EntitiesFields {
      var efs = compEntityFields[c];
      if (efs == null) {
        if (autoRegisterComponents) {
          // TODO What about dataDefs?
          efs = compEntityFields[c] = new Map();
        } else {
          throw new haxe.Exception("Component [" + c + "] doesn't exist and auto-registration is off");
        }
      }
      return efs;
    }

    public function interpret(nameEnv: Map<String, Lit>, e: Expr<Context>): Expr<Context> {
        return switch (e) {
            case ELit(_): e;
            case EBindNewEntity(n, ke):
                // TODO: how does this interact with ongoing query?
                //   new entities should only be available for query...
                //   ..acconding to the scheduling. Which is..
                var eid = addEntity();
                // TODO(nameenv): save previous? etc.
                nameEnv[n.name] = LEntity(eid);
                interpret(nameEnv, ke);
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
                    var eid = lookupNamedEidFromEnv(nameEnv, en.name);
                    var ctab = compEntityFields[cn.name];
                    if (ctab == null) throw new haxe.Exception("Unknown component: " + cn.name);
                    var eComp = ctab[eid];
                    if (eComp == null) {
                        throw new CutToQueryException();
                    }
                    // E: component doesn't have such field
                    //    (either can happen or not, depending on what upfront
                    //     checking we performed. No upfront checking now)
                    var n = eComp[fn.name];
                    if (n == null) {
                      throw new haxe.Exception("Component '" + cn.name + "' doesn't have field named '" + fn.name + "'");
                    }
                    // Unrelated wondering: Lit vs Const in AST?
                    //   Is this a hack that we are interpreting the parsed AST directly?

                    // For now we only have numeric fields.
                    ELit(LNum(n));
                case REntComp(_, _):
                    throw new haxe.Exception("Can't eval Comp ref (yet?)");
                case REntOrLocal(n):
                    // Locals we can resolve to the actual current value.
                    // Entities... we can only keep as entities.
                    var res = nameEnv[n.name];
                    if (res == null) {
                        throw new haxe.Exception("No local named '" + n.name + "' in scope.");
                    }
                    return ELit(res);
                }
            case EBinop(op, e1, e2):
                var ei1 = interpret(nameEnv, e1);
                var ei2 = interpret(nameEnv, e2);
                switch [ei1, ei2] {
                case [ELit(LNum(n1)), ELit(LNum(n2))]:
                    switch op {
                    case BAdd: ELit(LNum(n1 + n2));
                    case BSub: ELit(LNum(n1 - n2));
                    case BMul: ELit(LNum(n1 * n2));
                    case BDiv: ELit(LNum(n1 / n2));
                    case BLt: ELit(LBool(n1 < n2));
                    case BGt: ELit(LBool(n1 > n2));
                    case BEq: ELit(LBool(n1 == n2));  // Precision, in case numbers?
                    case BNe: ELit(LBool(n1 != n2));
                    case _: throw new haxe.Exception("Unimplemented num binop" + op);
                    }
                case [ELit(LBool(b1)), ELit(LBool(b2))]:
                    switch op {
                    case BEq: ELit(LBool(b1 == b2));
                    case _: throw new haxe.Exception("Unimplemented bool binop" + op);
                    }
                case [ELit(LEntity(n1)), ELit(LEntity(n2))]:
                    switch op {
                    case BEq: ELit(LBool(n1 == n2));
                    case BNe: ELit(LBool(n1 != n2));
                    case _: throw new haxe.Exception("Unimplemented entity binop" + op);
                    }
                case _: throw new haxe.Exception("Can't mix operand types in expr, or unsupported binop for types, or not literals");
                }
            case EEffect(f, ke):
                switch f {
                case FSet(r, e):
                    var ei = interpret(nameEnv, e);
                    switch r {
                    case REntField(en, cn, fn):
                        // TODO error handlings
                        // E: missing name
                        var eid = lookupNamedEidFromEnv(nameEnv, en.name);

                        // E: component doesn't exist?
                        var efs = ensureComponentAndGetEntitiesFields(cn.name);
                        var fs = efs[eid];
                        var entityHadComponentAlready = true;
                        if (fs == null) {
                          // TODO properly create all fields from datadef
                          fs = efs[eid] = new Map();
                          entityHadComponentAlready = false;
                        }
                        // TODO bool, other? Or actually check datadef?
                        fs[fn.name] = assertAsNum(ei);

                        var cfs = entityCompFields[eid];
                        var fs2 = cfs[cn.name];
                        if (fs2 == null) {
                          if (!entityHadComponentAlready) {
                            cfs[cn.name] = fs;
                          } else {
                            throw new haxe.Exception("Programming error: compEntityFields was present but entityCompFields was not: comp[" + cn.name + "] eid[" + eid + "]");
                          }
                        }
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
                        case ELit(LEntity(eid)):
                            nativeGfx.draw(entityCompFields.get(eid));
                        case _: throw new haxe.Exception("Need entity literal for !draw, got: " + ei);
                        }
                    }
                }
                interpret(nameEnv, ke);
            case EBindQuery(ann, n, ke):
                // For now mutate the nameEnv. We might want an immutabel version
                // later? Or only while in interactive/debug mode?
                // TODO(nameenv): unify handling of this.
                //   More a matter when we would have restricted scopes, which
                //   we now don't have.
                var prev = nameEnv[n.name];
                // Let's query the entities, and bind each in succession to the name
                // while executing the inner expression.
                var res = kArbitraryExpr;
                for (eid in entityCompFields.keys()) {
                    nameEnv[n.name] = LEntity(eid);
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
                if (prev == null) {
                  nameEnv.remove(n.name);
                } else {
                  nameEnv[n.name] = prev;
                }

                // Hack: this is kind of arbitrary and useless.
                // Should we support some kind of reducer over the produced results?
                // Might be more meaningful. Let's see if the need emerges
                // (but reducing can be emulated via using a local var etc.. let's
                // see when we have funcalls. So supporting at AST level, unless
                // some good reason, seems a bit overblown?)
                res;
            case EQueryCtrl(_ctx, c, ke):
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

function assertAsNum(e: Expr<Context>): Float {
    return switch e {
        case ELit(LNum(n)): n;
        case _: throw new haxe.Exception("Expected number, got: " + e);
    };
}
