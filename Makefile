##
# Brekkencs
#
# @file
# @version 0.1

.PHONY: setup devshell-hashlink compile fcompile compile-js fcompile-js compile-hl-c test ftest

setup:
	haxelib install utest
	haxelib git heaps https://github.com/HeapsIO/heaps
	# Note: installing from libs is not advised for these specific libs,
	# as they get stale quickly. Would be nice to pin the git versions though.
	# Maybe we can use separate git fetch + `haxelib dev` here.
	#haxelib install heaps
	#for compile-hl-c:
	haxelib install hashlink
	haxelib install hlsdl

devshell-hashlink:
	nix-shell -E 'with import <nixpkgs> { }; callPackage ./nix/hashlink.nix { }'

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
	haxe build-hl-c.hxml

# end
