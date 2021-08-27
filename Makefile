.PHONY: all bench build check clean configure fast haddock hlint main repl report run stan stylish test update

all: update fast bench

fast: main report

bench:
	rm -f helct-benchmark.tix
	cabal new-bench --jobs

build:
	cabal new-build --jobs --enable-profiling

check:
	cabal check

clean:
	cabal new-clean
	if test -d .cabal-sandbox; then cabal sandbox delete; fi
	if test -d .hpc; then rm -r .hpc; fi

configure:
	rm -f cabal.project.local*
	cabal configure --enable-benchmarks --enable-coverage --enable-tests

haddock:
	cabal new-haddock

hlint:
	./hlint.sh

main:
	make stylish configure check build test

repl:
	cabal new-repl lib:helct

report:
	make haddock stan hlint

run:
	cabal new-run --jobs helct

stan:
	./stan.sh

stylish:
	stylish-haskell -r -v -i hs

test:
	cabal new-test --jobs --test-show-details=streaming

update:
	cabal update
