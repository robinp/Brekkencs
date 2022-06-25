package ast;

import ast.Expr;

function s1(): Expr {
    var r: Ref = REntField(
                    mkName(null),
                    mkName("Pos"),
                    mkName("y"));
    return EQCtrl(
        CFilter(
            EBinop(BLt,
                ERef(r),
                ELit(LNum(100)))),
        EEffect(
            FSet(
                r,
                EBinop(BAdd, ERef(r), ELit(LNum(1)))),
            ELit(LBool(true))));
}
