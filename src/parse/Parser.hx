package parse;

import ast.Expr;
import ast.Context;

class Parser {
  private var pos: Int = 0;
  private var s: String;

  private static var P_OPEN = "(";
  private static var P_CLOSE = ")";

  public function new(s: String) {
    this.s = s;
  }

  public function atEnd() {
    skipSpaces();
    return pos >= s.length;
  }

  public function parseMany(): Array<Expr<Context>> {
    var res = [];
    while (pos < s.length) {
      skipSpaces();
      if (pos < s.length) {
        var e = parse();
        res.push(e);
      }
    }
    return res;
  }

  public function parse(): Expr<Context> {
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
      return EBindQuery(Context.next(), n, e);
    }
    if (tok == "new") {
      var n = parseName();
      var e = parse();
      return EBindNewEntity(n, e);
    }
    if (tok == "must") {
      var e1 = parse();
      var e2 = parse();
      return EQueryCtrl(Context.next(), QFilter(e1), e2);
    }
    if (tok == "set") {
      var e1 = parse();
      switch (e1) {
        case ERef(r):
          var e2 = parse();
          var e3 = parse();
          return EEffect(FSet(r, e2), e3);
        default:
          throw new haxe.Exception("expected reference arg to set around " + pos);
      }
    }
    if (tok == "draw!") {
      var e1 = parse();
      var e2 = parse();
      return EEffect(FNative(NDraw(e1)), e2);
    }

    // For now we don't have custom funcalls, so this must be a name ref.
    // Checking if it is a valid ref is deferred until interpretation time
    // for now. (Or at least to a separate analysis phase).
    var r = parseRefFrom(tok, p0, pos);
    return ERef(r);

    //throw new haxe.Exception("no parse: [" + tok + "] at pos " + p0 + ".." + pos);
  }

  private function parseRefFrom(tok: String, p0: Int, p1: Int): Ref {
    // TODO some more syntax validation
    if (tok.length == 0) {
      throw new haxe.Exception("empty-named reference (missing some expression?): [" + tok + "] at pos " + p0 + ".." + p1);
    }

    var parts = tok.split(".");
    if (parts.length > 3) {
      throw new haxe.Exception("too many parts in reference-like: [" + tok + "] at pos " + p0 + ".." + p1);
    }
    var nl: String = null;
    var nc: String = null;
    var nf: String = null;
    if (parts.length >= 1) {
      nl = parts[0];
      var startCh = nl.charAt(0);
      if (startCh.toLowerCase() != startCh) {
        throw new haxe.Exception("ref should be lower-case: [" + tok + "] at pos " + p0 + ".." + p1);
      }
    }
    if (parts.length >= 2) {
      nc = parts[1];
      var startCh = nc.charAt(0);
      if (startCh.toUpperCase() != startCh) {
        throw new haxe.Exception("component ref should be upper-case: [" + tok + "] at pos " + p0 + ".." + p1);
      }
    }
    if (parts.length >= 3) {
      nf = parts[2];
      var startCh = nf.charAt(0);
      if (startCh.toLowerCase() != startCh) {
        throw new haxe.Exception("field ref should be lower-case: [" + tok + "] at pos " + p0 + ".." + p1);
      }
    }
    if (nf != null) {
      return REntField(mkName(nl), mkName(nc), mkName(nf));
    }
    if (nc != null) {
      return REntComp(mkName(nl), mkName(nc));
    }
    return REntOrLocal(mkName(nl));
  }

  private function isAtLevelClosing() {
    return pos >= s.length || s.charAt(pos) == P_CLOSE;
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
      case ">": BGt;
      case "=": BEq;
      case "+": BAdd;
      case "-": BSub;
      case "*": BMul;
      case "/": BDiv;
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
