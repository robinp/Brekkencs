package parse;

import utest.Assert;

import ast.Expr;
import parse.Parser;

class ParserTest extends utest.Test {

  function testParenWrapNoop() {
    Assert.same(doParse("5"), doParse("(5)"));
    Assert.same(doParse("5"), doParse("((5))"));
  }

  function testNumLit() {
    Assert.same(ELit(LNum(5.0)), doParse("5"));
  }

  function testBoolLit() {
    Assert.same(ELit(LBool(true)), doParse("t"));
    Assert.same(ELit(LBool(false)), doParse("f"));
  }

  function testBinOp() {
    Assert.same(EBinop(BLt, ELit(LNum(3)), ELit(LNum(5))),
                doParse("(< 3 5)"));
    Assert.same(EBinop(BGt, ELit(LNum(3)), ELit(LNum(5))),
                doParse("(> 3 5)"));
    Assert.same(EBinop(BEq, ELit(LNum(3)), ELit(LNum(5))),
                doParse("(= 3 5)"));
    Assert.same(EBinop(BAdd, ELit(LNum(3)), ELit(LNum(5))),
                doParse("(+ 3 5)"));
    Assert.same(EBinop(BSub, ELit(LNum(3)), ELit(LNum(5))),
                doParse("(- 3 5)"));
    Assert.same(EBinop(BMul, ELit(LNum(3)), ELit(LNum(5))),
                doParse("(* 3 5)"));
    Assert.same(EBinop(BDiv, ELit(LNum(3)), ELit(LNum(5))),
                doParse("(/ 3 5)"));
  }

  function testQuery() {
    Assert.same(EBindQuery(mkName("x"), ELit(LNum(1))),
                doParse("(query x 1)"));
  }

  function testMust() {
    Assert.same(EQueryCtrl(QFilter(ELit(LBool(true))), ELit(LNum(3))),
                doParse("(must t 3)"));
  }

  function testLocalRef() {
    Assert.same(ERef(REntOrLocal(mkName("x"))), doParse("x"));
    Assert.same(ERef(REntOrLocal(mkName("x"))), doParse("(x)"));
  }

  function testComponentRef() {
    Assert.same(ERef(REntComp(mkName("x"), mkName("Foo"))),
                doParse("x.Foo"));
  }

  function testFieldRef() {
    Assert.same(ERef(REntField(mkName("x"), mkName("Foo"), mkName("z"))),
                doParse("x.Foo.z"));
  }

  function testBadRefs() {
    Assert.raises(() -> { doParse("X"); });
    Assert.raises(() -> { doParse("x.foo"); });
    Assert.raises(() -> { doParse("x.Foo.Bar"); });
    Assert.raises(() -> { doParse("x.Foo.bar.baz"); });
  }

  function testEffectSet() {
    Assert.same(EEffect(
                  FSet(REntOrLocal(mkName("x")), ELit(LNum(5))),
                  ELit(LBool(true))),
                doParse("(set x 5 t)"));
  }

  function testEffectNativeCall() {
    Assert.same(EEffect(
                  FNative(NDraw(ERef(REntOrLocal(mkName("x"))))),
                  ELit(LBool(true))),
                doParse("(draw! x t)"));
  }

  function testTooManyArgs() {
    Assert.raises(() -> { doParse("(draw! x t toomany)"); });
    Assert.raises(() -> { doParse("(foo bar)"); });
  }

  function testNoFullParse() {
    Assert.raises(() -> { doParse("bar baz"); });
  }

  function testRegressionCanParse() {
    doParse("(set e.Pos.y (+ e.Pos.y delta) (draw! e t))");
    Assert.isTrue(true);
  }

  private function doParse(s: String): Expr {
    var p = new Parser(s);
    var r = p.parse();
    if (!p.atEnd()) {
      throw new haxe.Exception("parsed [" + r + "] but didn't consume full input");
    }
    return r;
  }

}
