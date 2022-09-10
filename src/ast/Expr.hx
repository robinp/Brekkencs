package ast;

enum Expr {
    ELit(lit: Lit);
    ERef(r: Ref);
    EBinop(op: Binop, e1: Expr, e2: Expr);
    EEffect(eff: Effect, ke: Expr);
    EQueryCtrl(c: QueryCtrl, ke: Expr);
    // EParen
    EBindQuery(n: Name, ke: Expr);
    // EBind
    // ECtor
    // ENewEnt
}

enum Lit {
    LNum(v: Float);
    LBool(v: Bool);
    /** Note: can't be parsed directly, only by getting
     *  runtime reference.
     */
    LEntity(v: Int);
}

enum Binop {
    // Number
    BAdd;
    BSub;
    BDiv;
    BMul;
    // Bool
    BLt;
    BGt;
    // Overloaded
    BEq;
}

enum Effect {
    // Why we take ref here? It must eval to Ref, but can it be a generic expression?
    FSet(r: Ref, e: Expr);  // When? Deal with scheduling later..
    // FDelEnt
    // FDelComp
    FNative(nc: NativeCall);
}

// Not sure if there should be phases to this rather.
//
// Current ctors seem to conflate LHS-es (where we want to see only a limited
// set of access patterns, like below) and RHS-es (where the access is more
// free-form, and might mix in expressions).
enum Ref {
    // RLocal? Actually on a parser level, we can't (won't?) differentiate
    // between a local or an entity name ref. After type-checking or something
    // it might be more apparent. (And, locals can also be entity refs).
    REntOrLocal(en: Name);
    // Hm, maybe we should factor these to generic FieldAccess constructs?
    // Since if we have deeper field access etc, the current structure won't
    // fit. (Though, we might get away without deeper field access for now).
    REntField(en: Name, cn: Name, fn: Name);
    REntComp(en: Name, cn: Name);
}

// Maybe query control is a misleading name to this?
// Generally, it might not cut a query execution, but just evaluation of
// _some_ computation block. For example, if the user asserts `i < j` in some
// loop construct, the user would expect to only shortcut that loop scope.
//
// Well, we don't have explicit loops now. Maybe won't ever have.. that
// leaves only the cutting of the query as a possibility.
//
// If we had loops, would this act like a continue? Or would we need explicit
// marking of which level of nested control do we want to cut?
// Can that be the same concern with queries? In nested queries, how would we
// know which query to cut? Only the last etc? Or can we know based on the
// qualities of the expressions used in the filter (say, cut back to the
// last query which had its entity involved? Might need some dataflow analysis,
// once locals can be involved, but sounds the right thing... we should anyway
// have some liberty in reordering stuff as long semantics is not affected).
//
// How about funcalls eventually? Would a cut affect only rest of the function,
// or propagate beyond? Are cuts even allowed in functions? Sounds like local
// branching can have the same effect, so cuts are not really needed. Same with
// loops etc. So probably we should reserve "query control" really for queries,
// and have the semantics that supports whatever smooth/fast implementation we
// want.
enum QueryCtrl {
    QFilter(e: Expr);
    // sort etc
}

enum NativeCall {
    // Not sure we want to list them all on AST level.
    // Rather have some way for env to register these with their arities or so.
    NDraw(e: Expr);  // resolving to an entity ref
}

class Name {
    public var name: String;  // A bit too raw isn't it.

    public function new(n: String) { this.name = n; }
}

function mkName(n: String) { return new Name(n); }
