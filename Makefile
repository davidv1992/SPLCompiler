.PHONY: clean test version.h
#force version.h on every build

CXXFLAGS = -I. -g -Wall -Wextra -Wno-unused-parameter -Werror -std=c++11

test: test/tokentest test/parsetest

test/tokentest: testprogs/tokentest
	ls tests/parsing/correct/*.spl | xargs -n 1 valgrind --quiet ./testprogs/tokentest >/dev/null

test/parsetest: testprogs/parsetest
	ls tests/parsing/correct/*.spl | xargs -n 1 valgrind --quiet ./testprogs/parsetest >/dev/null

error.o: error.cpp error.h position.h
error.h: error.nw
	notangle -L -Rerror.h error.nw | cpif error.h
error.cpp: error.nw
	notangle -L -Rerror.cpp error.nw | cpif error.cpp

position.h: position.nw
	notangle -L -Rposition.h position.nw | cpif position.h

token.o: token.cpp token.h error.h position.h
token.h: token.nw
	notangle -L -Rtoken.h token.nw | cpif token.h
token.cpp: token.nw
	notangle -L -Rtoken.cpp token.nw | cpif token.cpp

ast.o: ast.cpp ast.h
ast.h: parser.nw
	notangle -L -Rast.h parser.nw | cpif ast.h
ast.cpp: parser.nw
	notangle -L -Rast.cpp parser.nw | cpif ast.cpp

parser.o: parser.cpp parser.h ast.h token.h error.h position.h settings.h
parser.h: parser.nw
	notangle -L -Rparser.h parser.nw | cpif parser.h
parser.cpp: parser.nw
	notangle -L -Rparser.cpp parser.nw | cpif parser.cpp

version.h:
	echo \#define VERSION \"`git describe --abbrev=4 --dirty --always --tags`\" | cpif version.h

settings.h:
	notangle -L -Rsettings.h settings.nw | cpif settings.h

code.tex: header.nw trailer.nw token.nw position.nw error.nw parser.nw settings.nw
	noweave -t4 -delay header.nw token.nw parser.nw settings.nw position.nw error.nw trailer.nw | cpif code.tex
code.pdf: code.tex
	latexmk -pdf code.tex
	latexmk -c

testprogs/tokentest: testprogs/tokentest.o token.o error.o
	g++ $(CXXFLAGS) -o testprogs/tokentest testprogs/tokentest.o token.o error.o
testprogs/tokentest.o: testprogs/tokentest.cpp token.h position.h
testprogs/tokentest.cpp: testprogs/tokentest.nw
	notangle -L -Rtokentest.cpp testprogs/tokentest.nw | cpif testprogs/tokentest.cpp

testprogs/parsetest: testprogs/parsetest.o token.o parser.o ast.o error.o
	g++ $(CXXFLAGS) -o testprogs/parsetest testprogs/parsetest.o token.o parser.o ast.o error.o
testprogs/parsetest.o: testprogs/parsetest.cpp token.h parser.h ast.h position.h
testprogs/parsetest.cpp: testprogs/parsetest.nw
	notangle -L -Rparsetest.cpp testprogs/parsetest.nw | cpif testprogs/parsetest.cpp

testprogs/typeparsetest: testprogs/typeparsetest.o token.o parser.o ast.o error.o
	g++ $(CXXFLAGS) -o testprogs/typeparsetest testprogs/typeparsetest.o token.o parser.o ast.o error.o
testprogs/typeparsetest.o: testprogs/typeparsetest.cpp token.h parser.h ast.h position.h
testprogs/typeparsetest.cpp: testprogs/typeparsetest.nw
	notangle -L -Rtypeparsetest.cpp testprogs/typeparsetest.nw | cpif testprogs/typeparsetest.cpp

testprogs/exprparsetest: testprogs/exprparsetest.o token.o parser.o ast.o error.o
	g++ $(CXXFLAGS) -o testprogs/exprparsetest testprogs/exprparsetest.o token.o parser.o ast.o error.o
testprogs/exprparsetest.o: testprogs/exprparsetest.cpp token.h parser.h ast.h position.h
testprogs/exprparsetest.cpp: testprogs/exprparsetest.nw
	notangle -L -Rexprparsetest.cpp testprogs/exprparsetest.nw | cpif testprogs/exprparsetest.cpp

testprogs/statementparsetest: testprogs/statementparsetest.o token.o parser.o ast.o error.o
	g++ $(CXXFLAGS) -o testprogs/statementparsetest testprogs/statementparsetest.o token.o parser.o ast.o error.o
testprogs/statementparsetest.o: testprogs/statementparsetest.cpp token.h parser.h ast.h position.h
testprogs/statementparsetest.cpp: testprogs/statementparsetest.nw
	notangle -L -Rstatementparsetest.cpp testprogs/statementparsetest.nw | cpif testprogs/statementparsetest.cpp

clean:
	rm -f error.h error.cpp error.o
	rm -f token.h token.cpp token.o
	rm -f ast.h ast.cpp ast.o
	rm -f parser.h parser.cpp parser.o
	rm -f testprogs/tokentest.cpp testprogs/tokentest.o testprogs/tokentest
	rm -f testprogs/parsetest.cpp testprogs/parsetest.o testprogs/parsetest
	rm -f testprogs/typeparsetest.cpp testprogs/typeparsetest.o testprogs/typeparsetest
	rm -f testprogs/exprparsetest.cpp testprogs/exprparsetest.o testprogs/exprparsetest
	rm -f testprogs/statementparsetest.cpp testprogs/statementparsetest.o testprogs/statementparsetest
	rm -f position.h version.h settings.h
	rm -f code.tex code.pdf
