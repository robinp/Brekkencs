##
# Brekkencs
#
# @file
# @version 0.1

.PHONY: setup

setup:
	haxelib install haxeui-core
	haxelib install haxeui-heaps
	haxelib git heaps https://github.com/HeapsIO/heaps
	# haxelib install heaps
	#haxelib git haxeui-heaps https://github.com/haxeui/haxeui-heaps

compile:
	haxe build.hxml

# end
