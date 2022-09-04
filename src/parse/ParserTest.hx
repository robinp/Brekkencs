package parse;

import utest.Assert;

import ast.Expr;
import parse.Parser;

class ParserTest extends utest.Test {

  function testNumLit() {
    Assert.same(ELit(LNum(5.0)), doParse("5"));
  }

  function testBoolLit() {
    Assert.same(ELit(LBool(true)), doParse("t"));
    Assert.same(ELit(LBool(false)), doParse("f"));
  }

  // TODO and this is where parsing shows possible
  // overconstrained AST. The Binop should be wrapped up
  // as Expr to parse nicely uniformly. Well, the parser
  // shouldn't drive the AST, but surely hints to some
  // more general problem here. If we want to allow
  // custom functions etc, then binops are just one kind
  // of the possible operators?
  function testBinOp() {
    Assert.same(BLt, doParse("<"));
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
