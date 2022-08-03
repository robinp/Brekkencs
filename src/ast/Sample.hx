package ast;

import ast.Expr;

// Note: needs "delta" in nameEnv.
function s1(): Expr {
    var e = mkName("<anonymous>");
    var er: Ref = REntOrLocal(e);
    var r: Ref = REntField(
                    e,
                    mkName("Pos"),
                    mkName("y"));
    return EBindQuery(e, EQueryCtrl(
        QFilter(
            EBinop(BLt,
                ERef(r),
                ELit(LNum(500)))),
        EEffect(
            FSet(
                r,
                EBinop(BAdd, ERef(r), ERef(REntOrLocal(mkName("delta"))))),
            EEffect(
                FNative(NDraw(ERef(er))),
                ERef(r)
            ))));
}
