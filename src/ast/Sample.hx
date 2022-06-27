package ast;

import ast.Expr;

function s1(): Expr {
    var e = mkName("<anonymous>");
    var r: Ref = REntField(
                    e,
                    mkName("Pos"),
                    mkName("y"));
    return EBindQuery(e, EQueryCtrl(
        QFilter(
            EBinop(BLt,
                ERef(r),
                ELit(LNum(100)))),
        EEffect(
            FSet(
                r,
                EBinop(BAdd, ERef(r), ELit(LNum(1)))),
            ERef(r)
            )));
}
