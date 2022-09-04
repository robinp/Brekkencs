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
    var c = curChar();
    if (c == P_OPEN) {
      // Tokenize the parts..
      return ELit(LBool(true));
    } else {
      var p0 = pos;
      skipUntilTokenDelimiter();
      var tok = s.substring(p0, pos);
      if (tok == "t") {
        return ELit(LBool(true));
      } else if (tok == "f") {
        return ELit(LBool(false));
      } else {
        var fOrNan = Std.parseFloat(tok);
        if (!Math.isNaN(fOrNan)) {
            return ELit(LNum(fOrNan));
        }
      }
      throw new haxe.Exception("no parse: [" + tok + "]");
    }
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

  private function assertNotOver() {
    if (pos >= s.length) {
      throw new haxe.Exception("Over input length");
    }
  }

  private function curChar(): String {
    return s.charAt(pos);
  }
}
