##
# Brekkencs
#
# @file
# @version 0.1

.PHONY: setup devshell-hashlink compile fcompile compile-js fcompile-js compile-hl-c test ftest

setup:
	# these are the versions that currently work with the nix-pinned deps
	haxelib install hlsdl  1.13.0
	haxelib install heaps  1.10.0
	haxelib install utest
	#for compile-hl-c:
	haxelib install hashlink 0.1.0
	haxelib install hlc-compiler 0.3.0

devshell-hashlink:
	nix-shell -E 'with import <nixpkgs> { }; callPackage ./nix/hashlink.nix { }'

server:
	haxe --server-listen 127.0.0.1:1222

test:
	haxe build-test.hxml
	hl ./out/Test.hl

ftest:
	haxe --connect 127.0.0.1:1222 build-test.hxml
	hl out/Test.hl

compile:
	haxe build.hxml

fcompile:
	haxe --connect 127.0.0.1:1222 build.hxml

compile-js:
	haxe build-js.hxml

fcompile-js:
	haxe --connect 127.0.0.1:1222 build-js.hxml

compile-hl-c:
	# See https://github.com/HeapsIO/heaps/issues/1132 about the sdl... generated.
	# in native code. Needs haxe 4.3+ for the fix
	haxe build-hl-c.hxml
	find out/c -type f | xargs sed -i 's/\?sdl/sdl/g'
	haxelib run hlc-compiler --srcDir out/c --srcFile Main.c --outDir out/bin --saveCmd out/compile_hlc.command --copyRuntimeFiles --hlLibDir /nix/store/calrd1anl2l407pcks1qpgahl8bm7yl7-hashlink-1.13.0/lib --hlIncludeDir /nix/store/calrd1anl2l407pcks1qpgahl8bm7yl7-hashlink-1.13.0/include
	# Above fails, but tune its linker commandline like:
	#  -lSDL2 -lhl -lm  (note the uppercase SDL2, and addition of -lm)

	# TODO mine these libs from $buildInputs or something.. or is there some
	# nix shim to automate this?
	patchelf --replace-needed libhl.so /nix/store/calrd1anl2l407pcks1qpgahl8bm7yl7-hashlink-1.13.0/lib/libhl.so out/bin/Main
	patchelf --replace-needed libSDL2-2.0.so.0 /nix/store/prlj29zdiqlbsip0j85lwnnqm7syaz4k-SDL2-2.26.5/lib/libSDL2-2.0.so.0 out/bin/Main
	# And it works \o/

