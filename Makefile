all:
	cd src; omake
test:	src/test.ml
	cd src; omake test
clean:
	cd src; omake clean
	rm -rf rillc rillc.opt example/*.cm* src/.omakedb
