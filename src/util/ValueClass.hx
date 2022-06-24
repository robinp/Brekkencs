package util;

// See https://code.haxe.org/category/macros/build-value-objects.html.
// TODO submit PR eventually with corrections / additions.

import haxe.macro.Expr;
import haxe.macro.Context;

@:remove @:autoBuild(util.ValueClassImpl.build())
extern interface ValueClass {}

class ValueClassImpl {
#if macro
  public static function build() {
    var fields = Context.getBuildFields();
    var args = [];
    var states = [];
    for (f in fields) {
      switch (f.kind) {
        case FVar(t, e):
          args.push({name:f.name, type:t, opt:false, value:null});
          states.push(macro $p{["this", f.name]} = $i{f.name});
          f.kind = FProp("default", "null", t, e);
          f.access.push(APublic);
        default:
      }
    }
    fields.push({
      name: "new",
      access: [APublic],
      pos: Context.currentPos(),
      kind: FFun({
        args: args,
        expr: macro $b{states},
        params: [],
        ret: null
      })
    });
    return fields;
  }
#end
}


@:remove @:autoBuild(util.MutableClassImpl.build())
extern interface MutableClass {}

class MutableClassImpl {
#if macro
  public static function build() {
    var fields = Context.getBuildFields();
    var args = [];
    var states = [];
    for (f in fields) {
      switch (f.kind) {
        case FVar(t,_):
          args.push({name:f.name, type:t, opt:false, value:null});
          states.push(macro $p{["this", f.name]} = $i{f.name});
          f.access.push(APublic);
        default:
      }
    }
    fields.push({
      name: "new",
      access: [APublic],
      pos: Context.currentPos(),
      kind: FFun({
        args: args,
        expr: macro $b{states},
        params: [],
        ret: null
      })
    });
    return fields;
  }
#end
}
