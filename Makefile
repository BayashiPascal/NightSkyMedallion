pov: clean nightsky.pov Makefile
	povray -D -P nightsky.ini

clean:
	rm -f nightsky*.png
