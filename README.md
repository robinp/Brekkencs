# BrekkEnCS

## Running

Get a `nix-shell`, and the first time do `make setup`. Then there are various targets:

### Desktop hashlink

`make compile` will build a hashlink-VM bytecode, which you can execute with hashlink using `hl out/Main.hl`.

### JS

`make compile-js` will compile via hashlink's JS output. Run it with opening `out/index.html` in the browser (see the JS console for trace output).

Note: for now only JS has interactive components for editing code.

### Native hashlink

`make compile-hl-c` will generate hashlink-native C code. Then you should compile that with Android NDK (code guide to come eventually).

Random pointers about some experimentation:

Stick to haxe 4.2.[1,3] since 4.2.[4,5] is allegedly buggy.
HL/C compile works after renaming the offending https://github.com/HaxeFoundation/haxe/issues/10734 in the C source.
See https://github.com/HaxeFoundation/hashlink/wiki/Android, https://github.com/fal-works/hlc-compiler-sample.

## Compiling faster

Use the haxe compile server:

```
haxe --server-listen 127.0.0.1:1222
```
then
```
haxe --connect 127.0.0.1:1222 build-js.hxml
```
