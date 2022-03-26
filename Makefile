.PHONY: test check
	
build:
	dune build

test:
	OCAMLRUNPARAM=b dune exec test/main.exe

test_tree:
	OCAMLRUNPARAM=b dune exec test/tree.exe

# test_expr:
#	OCAMLRUNPARAM=b dune exec test/expr.exe

testall: test test_tree

file:
	OCAMLRUNPARAM=b dune exec csv_example/csv1.exe

start:
	OCAMLRUNPARAM=b dune exec bin/main.exe

zip:
	rm -f camel_db.zip
	zip -r camel_db.zip . -x@exclude.lst

clean:
	dune clean
	rm -f camel_db.zip

doc:
	dune build @doc
