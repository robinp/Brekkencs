# BrekkEnCS

## Running

Get a `nix-shell`, and the first time do `make setup`. If you don't use nixpkgs,
could try to install the dependencies manually. But nix gives a more hermetic
build env, at least for the non-haxelib deps. (Might do a build docker
eventually?)

Then there are various targets:

### Desktop hashlink

`make compile` will build a hashlink-VM bytecode, which you can execute with hashlink using `hl out/Main.hl`.

Or, on non-nixOS, can try `nixGL hl out/Main.hl`. Practically:

```
nix run --impure github:guibou/nixGL -- hl out/Main.hl
```

### JS

`make compile-js` will compile via hashlink's JS output. Run it with opening `out/index.html` in the browser (see the JS console for trace output).

Note: for now only JS has interactive components for editing code.

### Native hashlink

`make compile-hl-c` will generate hashlink-native C code.

Random pointers about some experimentation:

Stick to haxe 4.2.[1,3] since 4.2.[4,5] is allegedly buggy (see hlc-compiler's
repo about it). See the Makefile's compile-hl-c, the instructions should give
you a working binary. Some manual patchelf for nixos is needed for now.

#### Android

You should compile that with Android NDK (code guide to come eventually).
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
