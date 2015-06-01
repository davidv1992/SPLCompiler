.PHONY: clean test limittest version.h
.PHONY: test/tokentest test/parsetest test/typechecktest test/irgentest test/compiler test/amd
.PHONY: limittest/comment limittest/bracket
.DEFAULT_GOAL := compiler
#force version.h on every build

BASH := /bin/bash
CXXFLAGS := -I. -g -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable -Werror -std=c++11

test: test/tokentest test/parsetest test/typechecktest test/irgentest test/compiler test/compileramd
	@$(BASH) -c "echo -e '\E[32mAll tests passed\E[0m'"

test/tokentest: testprogs/tokentest testprogs/tokencorrect.sh testprogs/tokenfail.sh
	$(BASH) ./testprogs/tokencorrect.sh
	$(BASH) ./testprogs/tokenfail.sh

test/parsetest: testprogs/parsetest testprogs/parsecorrect.sh testprogs/parsefail.sh testprogs/parsewarn.sh
	$(BASH) ./testprogs/parsecorrect.sh
	$(BASH) ./testprogs/parsefail.sh
	$(BASH) ./testprogs/parsewarn.sh

test/typechecktest: testprogs/typechecktest testprogs/typecheckcorrect.sh testprogs/typecheckfail.sh testprogs/typecheckwarn.sh
	$(BASH) ./testprogs/typecheckcorrect.sh
	$(BASH) ./testprogs/typecheckfail.sh
	$(BASH) ./testprogs/typecheckwarn.sh

test/irgentest: testprogs/irgentest testprogs/irgencorrect.sh
	$(BASH) ./testprogs/irgencorrect.sh

test/compiler: compiler testprogs/compilercorrect.sh
	$(BASH) ./testprogs/compilercorrect.sh

test/compileramd: compiler testprogs/amdcorrect.sh cplatform.c
	$(BASH) ./testprogs/amdcorrect.sh

limittest: limittest/comment limittest/bracket
	@$(BASH) -c "echo -e '\E[32mAll tests passed\E[0m'"

limittest/comment: testprogs/parsetest testprogs/runtolim.sh testprogs/commentgen
	$(BASH) ./testprogs/runtolim.sh ./testprogs/commentgen 50000

limittest/bracket: testprogs/parsetest testprogs/runtolim.sh testprogs/bracketgen
	$(BASH) ./testprogs/runtolim.sh ./testprogs/bracketgen 5000

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
ast.h: ast.nw
	notangle -L -Rast.h ast.nw | cpif ast.h
ast.cpp: ast.nw
	notangle -L -Rast.cpp ast.nw | cpif ast.cpp

ir.h: ir.nw
	notangle -L -Rir.h ir.nw | cpif ir.h

constprop.o: constprop.cpp constprop.h ir.h
constprop.h: constprop.nw
	notangle -L -Rconstprop.h constprop.nw | cpif constprop.h
constprop.cpp: constprop.nw
	notangle -L -Rconstprop.cpp constprop.nw | cpif constprop.cpp

irutil.o: irutil.cpp irutil.h ir.h
irutil.h: irutils.nw
	notangle -L -Rirutil.h irutils.nw | cpif irutil.h
irutil.cpp: irutils.nw
	notangle -L -Rirutil.cpp irutils.nw | cpif irutil.cpp

assembly.o: assembly.cpp assembly.h
assembly.h: assembly.nw
	notangle -L -Rassembly.h assembly.nw | cpif assembly.h
assembly.cpp: assembly.nw
	notangle -L -Rassembly.cpp assembly.nw | cpif assembly.cpp

ssm.o: ssm.cpp assembly.h ir.h ssm.h irutil.h
ssm.h: ssm.nw
	notangle -L -Rssm.h ssm.nw | cpif ssm.h
ssm.cpp: ssm.nw
	notangle -L -Rssm.cpp ssm.nw | cpif ssm.cpp

parser.o: parser.cpp parser.h ast.h token.h error.h position.h settings.h
parser.h: parser.nw
	notangle -L -Rparser.h parser.nw | cpif parser.h
parser.cpp: parser.nw
	notangle -L -Rparser.cpp parser.nw | cpif parser.cpp

typecheck.o: typecheck.cpp ast.h typecheck.h error.h
typecheck.h: typecheck.nw
	notangle -L -Rtypecheck.h typecheck.nw | cpif typecheck.h
typecheck.cpp: typecheck.nw
	notangle -L -Rtypecheck.cpp typecheck.nw | cpif typecheck.cpp

irgeneration.o: irgeneration.cpp irgeneration.h ast.h ir.h typecheck.h position.h settings.h
irgeneration.h: irgeneration.nw
	notangle -L -Rirgeneration.h irgeneration.nw | cpif irgeneration.h
irgeneration.cpp: irgeneration.nw
	notangle -L -Rirgeneration.cpp irgeneration.nw | cpif irgeneration.cpp

splruntime.o: splruntime.cpp ir.h irgeneration.h ast.h position.h
splruntime.h: splruntime.nw
	notangle -L -Rsplruntime.h splruntime.nw | cpif splruntime.h
splruntime.cpp: splruntime.nw
	notangle -L -Rsplruntime.cpp splruntime.nw | cpif splruntime.cpp

main.o: main.cpp token.h parser.h ast.h position.h typecheck.h ir.h irgeneration.h settings.h splruntime.h ssm.h error.h amd64.h constprop.h position.h
main.cpp: main.nw
	notangle -L -Rmain.cpp main.nw | cpif main.cpp

compiler: main.o token.o parser.o ast.o error.o typecheck.o irgeneration.o settings.o splruntime.o ssm.o irutil.o assembly.o amd64.o constprop.o
	g++ $(CXXFLASGS) -o compiler main.o token.o parser.o ast.o error.o typecheck.o irgeneration.o settings.o splruntime.o ssm.o irutil.o assembly.o amd64.o constprop.o

amd64.o: amd64.cpp amd64.h assembly.h ir.h irutil.h
amd64.h: amd64.nw
	notangle -L -Ramd64.h amd64.nw | cpif amd64.h
amd64.cpp: amd64.nw
	notangle -L -Ramd64.cpp amd64.nw | cpif amd64.cpp

cplatform.c: amd64.nw
	notangle -L -Rcplatform.c amd64.nw | cpif cplatform.c

version.h:
	echo \#define VERSION \"`git describe --abbrev=4 --dirty --always --tags`\" | cpif version.h

settings.o: settings.cpp settings.h version.h
settings.cpp: settings.nw token.nw parser.nw typecheck.nw error.nw ir.nw irgeneration.nw ssm.nw main.nw
	notangle -L -Rsettings.cpp token.nw parser.nw typecheck.nw error.nw ir.nw irgeneration.nw ssm.nw settings.nw main.nw | cpif settings.cpp
settings.h: settings.nw token.nw parser.nw typecheck.nw error.nw ir.nw irgeneration.nw ssm.nw main.nw
	notangle -L -Rsettings.h token.nw parser.nw typecheck.nw error.nw ir.nw irgeneration.nw ssm.nw settings.nw main.nw | cpif settings.h

test.tex: testprogs/testheader.nw testprogs/testtrailer.nw testprogs/tokentest.nw testprogs/parsetest.nw testprogs/exprparsetest.nw testprogs/typeparsetest.nw testprogs/irgentest.nw testprogs/compilertest.nw testprogs/statementparsetest.nw testprogs/stresstest.nw
	noweave -t4 -delay testprogs/testheader.nw testprogs/tokentest.nw testprogs/parsetest.nw testprogs/typeparsetest.nw testprogs/exprparsetest.nw testprogs/statementparsetest.nw testprogs/irgentest.nw testprogs/compilertest.nw testprogs/stresstest.nw testprogs/testtrailer.nw | cpif test.tex
test.pdf: test.tex
	latexmk -pdf test.tex
	latexmk -c

code.tex: header.nw trailer.nw token.nw position.nw error.nw parser.nw settings.nw spllang.nw ast.nw typecheck.nw ir.nw irgeneration.nw main.nw splruntime.nw ssm.nw assembly.nw irutils.nw amd64.nw constprop.nw
	noweave -t4 -delay header.nw spllang.nw ast.nw token.nw parser.nw typecheck.nw ir.nw irgeneration.nw splruntime.nw constprop.nw irutils.nw assembly.nw ssm.nw amd64.nw main.nw settings.nw position.nw error.nw trailer.nw | cpif code.tex
code.pdf: code.tex compiler.bib
	latexmk -pdf code.tex
	latexmk -c

testprogs/tokentest: testprogs/tokentest.o token.o error.o settings.o
	g++ $(CXXFLAGS) -o testprogs/tokentest testprogs/tokentest.o token.o error.o settings.o
testprogs/tokentest.o: testprogs/tokentest.cpp token.h position.h
testprogs/tokentest.cpp: testprogs/tokentest.nw
	notangle -L -Rtokentest.cpp testprogs/tokentest.nw | cpif testprogs/tokentest.cpp

testprogs/parsetest: testprogs/parsetest.o token.o parser.o ast.o error.o settings.o
	g++ $(CXXFLAGS) -o testprogs/parsetest testprogs/parsetest.o token.o parser.o ast.o error.o settings.o
testprogs/parsetest.o: testprogs/parsetest.cpp token.h parser.h ast.h position.h
testprogs/parsetest.cpp: testprogs/parsetest.nw
	notangle -L -Rparsetest.cpp testprogs/parsetest.nw | cpif testprogs/parsetest.cpp

testprogs/typeparsetest: testprogs/typeparsetest.o token.o parser.o ast.o error.o settings.o
	g++ $(CXXFLAGS) -o testprogs/typeparsetest testprogs/typeparsetest.o token.o parser.o ast.o error.o settings.o
testprogs/typeparsetest.o: testprogs/typeparsetest.cpp token.h parser.h ast.h position.h
testprogs/typeparsetest.cpp: testprogs/typeparsetest.nw
	notangle -L -Rtypeparsetest.cpp testprogs/typeparsetest.nw | cpif testprogs/typeparsetest.cpp

testprogs/exprparsetest: testprogs/exprparsetest.o token.o parser.o ast.o error.o settings.o
	g++ $(CXXFLAGS) -o testprogs/exprparsetest testprogs/exprparsetest.o token.o parser.o ast.o error.o settings.o
testprogs/exprparsetest.o: testprogs/exprparsetest.cpp token.h parser.h ast.h position.h
testprogs/exprparsetest.cpp: testprogs/exprparsetest.nw
	notangle -L -Rexprparsetest.cpp testprogs/exprparsetest.nw | cpif testprogs/exprparsetest.cpp

testprogs/statementparsetest: testprogs/statementparsetest.o token.o parser.o ast.o error.o settings.o
	g++ $(CXXFLAGS) -o testprogs/statementparsetest testprogs/statementparsetest.o token.o parser.o ast.o error.o settings.o
testprogs/statementparsetest.o: testprogs/statementparsetest.cpp token.h parser.h ast.h position.h
testprogs/statementparsetest.cpp: testprogs/statementparsetest.nw
	notangle -L -Rstatementparsetest.cpp testprogs/statementparsetest.nw | cpif testprogs/statementparsetest.cpp

testprogs/typechecktest: testprogs/typechecktest.o token.o parser.o ast.o error.o typecheck.o settings.o
	g++ $(CXXFLAGS) -o testprogs/typechecktest testprogs/typechecktest.o token.o parser.o ast.o error.o typecheck.o settings.o
testprogs/typechecktest.o: testprogs/typechecktest.cpp token.h parser.h ast.h position.h typecheck.h
testprogs/typechecktest.cpp: testprogs/typechecktest.nw
	notangle -L -Rtypechecktest.cpp testprogs/typechecktest.nw | cpif testprogs/typechecktest.cpp

testprogs/irgentest: testprogs/irgentest.o token.o parser.o ast.o error.o typecheck.o irgeneration.o settings.o splruntime.o
	g++ $(CXXFLAGS) -o testprogs/irgentest testprogs/irgentest.o token.o parser.o ast.o error.o typecheck.o irgeneration.o settings.o splruntime.o
testprogs/irgentest.o: testprogs/irgentest.cpp token.h parser.h ast.h position.h typecheck.h ir.h irgeneration.h splruntime.h
testprogs/irgentest.cpp: testprogs/irgentest.nw
	notangle -L -Rirgentest.cpp testprogs/irgentest.nw | cpif testprogs/irgentest.cpp

testprogs/printruntime: testprogs/printruntime.o splruntime.o
	g++ $(CXXFLAGS) -o testprogs/printruntime testprogs/printruntime.o splruntime.o
testprogs/printruntime.o: testprogs/printruntime.cpp ir.h splruntime.h
testprogs/printruntime.cpp: testprogs/printruntime.nw
	notangle -L -Rprintruntime.cpp testprogs/printruntime.nw | cpif testprogs/printruntime.cpp

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

testprogs/typecheckcorrect.sh: testprogs/typechecktest.nw
	notangle -L -Rtypecheckcorrect.sh testprogs/typechecktest.nw > testprogs/typecheckcorrect.sh
	chmod +x testprogs/typecheckcorrect.sh

testprogs/typecheckfail.sh: testprogs/typechecktest.nw
	notangle -L -Rtypecheckfail.sh testprogs/typechecktest.nw > testprogs/typecheckfail.sh
	chmod +x testprogs/typecheckfail.sh

testprogs/typecheckwarn.sh: testprogs/typechecktest.nw
	notangle -L -Rtypecheckwarn.sh testprogs/typechecktest.nw > testprogs/typecheckwarn.sh
	chmod +x testprogs/typecheckwarn.sh

testprogs/irgencorrect.sh: testprogs/irgentest.nw
	notangle -L -Rirgencorrect.sh testprogs/irgentest.nw > testprogs/irgencorrect.sh
	chmod +x testprogs/irgencorrect.sh

testprogs/compilercorrect.sh: testprogs/compilertest.nw
	notangle -L -Rcompilercorrect.sh testprogs/compilertest.nw > testprogs/compilercorrect.sh
	chmod +x testprogs/compilercorrect.sh

testprogs/amdcorrect.sh: testprogs/compilertest.nw
	notangle -L -Ramdcorrect.sh testprogs/compilertest.nw > testprogs/amdcorrect.sh
	chmod +x testprogs/amdcorrect.sh

testprogs/commentgen: testprogs/commentgen.cpp
testprogs/commentgen.cpp: testprogs/stresstest.nw
	notangle -L -Rcommentgen.cpp testprogs/stresstest.nw | cpif testprogs/commentgen.cpp

testprogs/bracketgen: testprogs/bracketgen.cpp
testprogs/bracketgen.cpp: testprogs/stresstest.nw
	notangle -L -Rbracketgen.cpp testprogs/stresstest.nw | cpif testprogs/bracketgen.cpp

testprogs/runtolim.sh: testprogs/stresstest.nw
	notangle -L -Rruntolim.sh testprogs/stresstest.nw > testprogs/runtolim.sh
	chmod +x testprogs/runtolim.sh

clean:
	rm -f error.h error.cpp error.o
	rm -f token.h token.cpp token.o
	rm -f ast.h ast.cpp ast.o
	rm -f parser.h parser.cpp parser.o
	rm -f typecheck.h typecheck.cpp typecheck.o
	rm -f main.cpp main.o compiler
	rm -f irgeneration.h irgeneration.cpp irgeneration.o
	rm -f splruntime.h splruntime.cpp splruntime.o
	rm -f assembly.h assembly.cpp assembly.o
	rm -f irutil.h irutil.cpp irutil.o
	rm -f constprop.h constprop.cpp constprop.o
	rm -f settings.h settings.cpp settings.o
	rm -f position.h version.h ir.h
	rm -f ssm.h ssm.cpp ssm.o
	rm -f amd64.h amd64.cpp amd64.o cplatform.c
	rm -f testprogs/tokentest.cpp testprogs/tokentest.o testprogs/tokentest
	rm -f testprogs/parsetest.cpp testprogs/parsetest.o testprogs/parsetest
	rm -f testprogs/typeparsetest.cpp testprogs/typeparsetest.o testprogs/typeparsetest
	rm -f testprogs/exprparsetest.cpp testprogs/exprparsetest.o testprogs/exprparsetest
	rm -f testprogs/statementparsetest.cpp testprogs/statementparsetest.o testprogs/statementparsetest
	rm -f testprogs/typechecktest.cpp testprogs/typechecktest.o testprogs/typechecktest
	rm -f testprogs/printruntime.cpp testprogs/printruntime.o testprogs/printruntime
	rm -f testprogs/irgentest.cpp testprogs/irgentest.o testprogs/irgentest
	rm -f testprogs/parsecorrect.sh testprogs/parsefail.sh testprogs/parsewarn.sh
	rm -f testprogs/typecheckcorrect.sh testprogs/typecheckfail.sh testprogs/typecheckwarn.sh
	rm -f testprogs/irgencorrect.sh testprogs/compilercorrect.sh testprogs/amdcorrect.sh
	rm -f testprogs/tokencorrect.sh testprogs/tokenfail.sh
	rm -f testprogs/commentgen testprogs/commentgen.cpp
	rm -f testprogs/bracketgen testprogs/bracketgen.cpp
	rm -f testprogs/runtolim.sh
	rm -f code.tex code.pdf code.bbl
	rm -f test.tex test.pdf
