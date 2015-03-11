.PHONY: clean test version.h
#force version.h on every build

BASH := /bin/bash
CXXFLAGS := -I. -g -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable -Werror -std=c++11

test: test/tokentest test/parsetest
	@$(BASH) -c "echo -e '\E[32mAll tests passed\E[0m'"

test/tokentest: testprogs/tokentest testprogs/tokencorrect.sh testprogs/tokenfail.sh
	$(BASH) ./testprogs/tokencorrect.sh
	$(BASH) ./testprogs/tokenfail.sh

test/parsetest: testprogs/parsetest testprogs/parsecorrect.sh testprogs/parsefail.sh testprogs/parsewarn.sh
	$(BASH) ./testprogs/parsecorrect.sh
	$(BASH) ./testprogs/parsefail.sh
	$(BASH) ./testprogs/parsewarn.sh

error.o: error.cpp error.h position.h settings.h
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

settings.h: settings.nw
	notangle -L -Rsettings.h settings.nw | cpif settings.h

test.tex: testprogs/testheader.nw testprogs/testtrailer.nw testprogs/tokentest.nw testprogs/parsetest.nw testprogs/exprparsetest.nw testprogs/typeparsetest.nw testprogs/statementparsetest.nw
	noweave -t4 -delay testprogs/testheader.nw testprogs/tokentest.nw testprogs/parsetest.nw testprogs/typeparsetest.nw testprogs/exprparsetest.nw testprogs/statementparsetest.nw testprogs/testtrailer.nw | cpif test.tex
test.pdf: test.tex
	latexmk -pdf test.tex
	latexmk -c

code.tex: header.nw trailer.nw token.nw position.nw error.nw parser.nw settings.nw spllang.nw
	noweave -t4 -delay header.nw spllang.nw token.nw parser.nw settings.nw position.nw error.nw trailer.nw | cpif code.tex
code.pdf: code.tex compiler.bib
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

testprogs/parsecorrect.sh: testprogs/parsetest.nw
	notangle -L -Rparsecorrect.sh testprogs/parsetest.nw > testprogs/parsecorrect.sh
	chmod +x testprogs/parsecorrect.sh

testprogs/parsefail.sh: testprogs/parsetest.nw
	notangle -L -Rparsefail.sh testprogs/parsetest.nw > testprogs/parsefail.sh
	chmod +x testprogs/parsefail.sh

testprogs/parsewarn.sh: testprogs/parsetest.nw
	notangle -L -Rparsewarn.sh testprogs/parsetest.nw > testprogs/parsewarn.sh
	chmod +x testprogs/parsewarn.sh

testprogs/tokencorrect.sh: testprogs/tokentest.nw
	notangle -L -Rtokencorrect.sh testprogs/tokentest.nw > testprogs/tokencorrect.sh
	chmod +x testprogs/tokencorrect.sh

testprogs/tokenfail.sh : testprogs/tokentest.nw
	notangle -L -Rtokenfail.sh testprogs/tokentest.nw > testprogs/tokenfail.sh
	chmod +x testprogs/tokenfail.sh

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
	rm -f testprogs/parsecorrect.sh testprogs/parsefail.sh testprogs/parsewarn.sh
	rm -f testprogs/tokencorrect.sh testprogs/tokenfail.sh
	rm -f position.h version.h settings.h
	rm -f code.tex code.pdf code.bbl
	rm -f test.tex test.pdf
