MAKEFLAGS += --always-make

install:
	pdm install -d

test:
	pdm run test

clean:
	pdm run clean

clean_tf:
	pdm run clean_tf

clean_all:
	pdm run clean_all

mytest:
	pdm run mytest
