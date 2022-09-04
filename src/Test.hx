import utest.Runner;
import utest.ui.Report;

class Test {
  public static function main() {
    /* the long way
    var runner = new Runner();
    runner.addCase(new TestCase1());
    runner.addCase(new TestCase2());
    Report.create(runner);
    runner.run();
    */

    utest.UTest.run([new parse.ParserTest()]);
  }
}
