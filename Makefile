all:
	cd src; omake

clean:
	cd src; omake clean
	rm -rf rillc rillc.opt example/*.cm* src/.omakedb
