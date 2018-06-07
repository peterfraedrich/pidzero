
run:
	haxe -main Pzd --interp

test:
	haxe -main Pzd -cpp build/
	cp build/Pzd .
	./Pzd

compile:
	haxe -main Pzd -dce full -D analyzer-optimize -cpp build/
	rm -rf dist/*
	cp build/Pzd dist/pidzero
	cp config.json dist/.
	cp daemons.json dist/.
