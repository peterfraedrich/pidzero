
run:
	haxe -main Pzd --interp

test:
	haxe -main Pzd -cpp build/
	cp build/Pzd .
	./Pzd

compile:
	haxe -v -main Pzd -cp . -dce full -D analyzer-optimize -D source-header="pidzero 1.0" -D HXCPP_M64 -D static -lib hxcpp -cpp build/
	-rm -rf dist
	mkdir dist
	cp build/Pzd dist/pidzero
	cp config.json dist/.
	cp daemons.json dist/.
