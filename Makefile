##
# Brekkencs
#
# @file
# @version 0.1

.PHONY: setup

setup:
	haxelib git haxeui-core https://github.com/haxeui/haxeui-core
	haxelib git haxeui-heaps https://github.com/haxeui/haxeui-heaps
	haxelib git heaps https://github.com/HeapsIO/heaps
	# Note: installing from libs is not advised for these specific libs,
	# as they get stale quickly. Would be nice to pin the git versions though.
	# Maybe we can use separate git fetch + `haxelib dev` here.
	#haxelib install haxeui-core
	#haxelib install haxeui-heaps
	#haxelib install heaps
	#for compile-hl-c:
	haxelib install hashlink

compile:
	haxe build.hxml

compile-hl-c:
	haxe build-hl-c.hxml

# end
