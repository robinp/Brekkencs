package ast;

class Context {
  private static var NEXT_ID: Int = 0;

  public var id: Int;

  public static function next(): Context {
    return new Context(NEXT_ID++);
  }

  public function new(id: Int) {
    this.id = id;
  }
}
