package ast;

import ast.Context;
import ast.Expr;

// Note: needs "delta" in nameEnv.
function s1(): Expr<Context> {
    var n = mkName("<anonymous>");
    var er: Ref = REntOrLocal(n);
    var r: Ref = REntField(
                    n,
                    mkName("Pos"),
                    mkName("y"));
    return EBindQuery(Context.next(), n, EQueryCtrl(
        Context.next(),
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
