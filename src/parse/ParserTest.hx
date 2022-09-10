package parse;

import utest.Assert;

import ast.Expr;
import parse.Parser;

class ParserTest extends utest.Test {

  function testNumLit() {
    Assert.same(ELit(LNum(5.0)), doParse("5"));
  }

  function testParenWrapNoop() {
    Assert.same(doParse("5"), doParse("(5)"));
    Assert.same(doParse("5"), doParse("((5))"));
  }

  function testBoolLit() {
    Assert.same(ELit(LBool(true)), doParse("t"));
    Assert.same(ELit(LBool(false)), doParse("f"));
  }

  function testBinOp() {
    Assert.same(EBinop(BLt, ELit(LNum(3)), ELit(LNum(5))),
                doParse("(< 3 5)"));
  }

  function testQuery() {
    Assert.same(EBindQuery(mkName("x"), ELit(LNum(1))),
                doParse("(query x 1)"));
  }

  function testMust() {
    Assert.same(EQueryCtrl(QFilter(ELit(LBool(true))), ELit(LNum(3))),
                doParse("(must t 3)"));
  }

  function testGarbage() {
    Assert.raises(() -> {
        doParse("%=!");
    });
  }

  private function doParse(s: String): Expr {
    var p = new Parser(s);
    return p.parse();
  }

}
