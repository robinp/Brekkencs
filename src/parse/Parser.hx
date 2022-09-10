package parse;

import ast.Expr;

class Parser {
  private var pos: Int = 0;
  private var s: String;

  private static var P_OPEN = "(";
  private static var P_CLOSE = ")";

  public function new(s: String) {
    this.s = s;
  }

  public function parse(): Expr {
    skipSpaces();
    assertNotOver();
    if (curChar() == P_OPEN) {
      pos += 1;
      var e = parse();
      skipSpaces();
      if (curChar() != P_CLOSE) {
        throw new haxe.Exception("Expected ) at pos " + pos);
      }
      pos += 1;
      return e;
    }
    var p0 = pos;
    skipUntilTokenDelimiter();
    var tok = s.substring(p0, pos);
    if (tok == "t") {
      return ELit(LBool(true));
    }
    if (tok == "f") {
      return ELit(LBool(false));
    }
    // TODO assert this is the first token in sexp.
    var mbBinop  = parseBinop(tok);
    if (mbBinop != null) {
      var e1 = parse();
      var e2 = parse();
      return EBinop(mbBinop, e1, e2);
    }
    var fOrNan = Std.parseFloat(tok);
    if (!Math.isNaN(fOrNan)) {
      return ELit(LNum(fOrNan));
    }
    // TODO assert this is the first token in sexp.
    if (tok == "query") {
      var n = parseName();
      var e = parse();
      return EBindQuery(n, e);
    }
    if (tok == "must") {
      var e1 = parse();
      var e2 = parse();
      return EQueryCtrl(QFilter(e1), e2);
    }
    throw new haxe.Exception("no parse: [" + tok + "] at pos " + p0 + ".." + pos);
  }

  private function skipSpaces() {
    while (pos < s.length && StringTools.isSpace(s, pos)) {
      pos += 1;
    }
  }

  private function skipUntilTokenDelimiter() {
    while (pos < s.length && !(
            StringTools.isSpace(s, pos) || s.charAt(pos) == P_CLOSE || s.charAt(pos) == P_OPEN)) {
      pos += 1;
    }
  }

  private function parseBinop(s: String): Null<Binop> {
    return switch (s) {
      case "<": BLt;
      case "=": BEq;
      default: null;
    }
  }

  private function parseName() {
    skipSpaces();
    var p0 = pos;
    // TODO any restriction on names?
    //   should disallow keywords for example.
    skipUntilTokenDelimiter();
    return mkName(s.substring(p0, pos));
  }

  private function assertNotOver() {
    if (pos >= s.length) {
      throw new haxe.Exception("Over input length");
    }
  }

  private function curChar(): String {
    return s.charAt(pos);
  }
}
