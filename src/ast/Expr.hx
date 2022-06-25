package ast;

enum Expr {
    ELit(lit: Lit);
    ERef(r: Ref);
    EBinop(op: Binop, e1: Expr, e2: Expr);
    EEffect(eff: Effect, ke: Expr);
    EQCtrl(c: QCtrl, ke: Expr);
    // EParen
    // EBindQuery
    // EBind
    // ECtor
    // ENewEnt
}

enum Lit {
    LNum(v: Float);
    LBool(v: Bool);
}

enum Binop {
    BAdd;
    BSub;
    BDiv;
    BMul;
    BLt;
}

enum Effect {
    FSet(r: Ref, e: Expr);  // When
    // FDelEnt
    // FDelComp
}

// Not sure if there should be phases to this rather.
enum Ref {
    // RLocal?
    // REnt
    REntField(en: Name, cn: Name, fn: Name);
    REntComp(en: Name, cn: Name);
}

enum QCtrl {
    CFilter(e: Expr);
    // CSort
}

class Name {
    public var name: String;  // A bit too raw isn't it.

    public function new(n: String) { this.name = n; }
}

function mkName(n: String) { return new Name(n); }
