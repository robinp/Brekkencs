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
    assertNotOver();
    var c = curChar();
    if (c == P_OPEN) {
      // Tokenize the parts..
      return ELit(LBool(true));
    } else {
      return ELit(LBool(false));
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
