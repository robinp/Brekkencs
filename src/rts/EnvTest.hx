package rts;

import utest.Assert;

import ast.Context;
import ast.Expr;
import parse.Parser;

import rts.DataDefs;

class DummyGfx implements NativeGfx {
  public function new() {}
  public function clear() {}
  public function draw(comps: Map<TypeName, Map<String, Float>>) {}
}

class EnvTest extends utest.Test {

  private var gfx = new DummyGfx();

  function testNumLit() {
    var env = new Env(gfx);
    var res = env.interpret([], doParse("5"));
    Assert.same(ELit(LNum(5.0)), res);
  }

  function testFailedQuery() {
    var env = new Env(gfx);
    var res = env.interpret([], doParse("(query k (must f t))"));
    Assert.same(ELit(LNum(42001)), res);  // see code for dummy value
  }

  function testSuccessfulQueryWithoutSubjects() {
    var env = new Env(gfx);
    var res = env.interpret([], doParse("(query k (must t t))"));
    // Condition is true, but there aren't any entities yet to iterate on.
    Assert.same(ELit(LNum(42001)), res);  // see code for dummy value
  }

  function testNewEntity() {
    var env = new Env(gfx);
    var res = env.interpret([], doParse("(new e t)"));
    Assert.same(ELit(LBool(true)), res);
    Assert.same(1, env.entityCount());
  }

  function testSuccessfulQueryWithUnrelatedSubject() {
    var env = new Env(gfx);
    env.interpret([], doParse("(new e t)"));
    var res = env.interpret([], doParse("(query k (must t t))"));
    Assert.same(ELit(LBool(true)), res);
  }

  function testSuccessfulQuery_WithUnrelatedSubject_WithNameLookupInCond() {
    var env = new Env(gfx);
    env.interpret([], doParse("(new e t)"));
    var res = env.interpret(
        ["step" => LNum(1)],
        doParse("(query k (must (= step 1) step))"));
    Assert.same(ELit(LNum(1)), res);
  }

  private function doParse(s: String): Expr<Context> {
    var p = new Parser(s);
    var r = p.parse();
    if (!p.atEnd()) {
      throw new haxe.Exception("parsed [" + r + "] but didn't consume full input");
    }
    return r;
  }

}
