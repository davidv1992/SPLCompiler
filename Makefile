.PHONY: clean

CXXFLAGS = -I. -g

error.o: error.cpp error.h position.h
error.h: error.nw
	notangle -L -Rerror.h error.nw > error.h
error.cpp: error.nw
	notangle -L -Rerror.cpp error.nw > error.cpp
	
position.h: position.nw
	notangle -L -Rposition.h position.nw > position.h

token.o: token.cpp token.h error.h position.h
token.h: token.nw
	notangle -L -Rtoken.h token.nw > token.h
token.cpp: token.nw
	notangle -L -Rtoken.cpp token.nw > token.cpp

code.tex: token.nw position.nw error.nw
	noweave -t4 token.nw position.nw error.nw > code.tex
code.pdf: code.tex
	pdflatex code.tex

testprogs/tokentest: testprogs/tokentest.o token.o error.o
	g++ -o testprogs/tokentest testprogs/tokentest.o token.o error.o -g
testprogs/tokentest.o: testprogs/tokentest.cpp token.h position.h
testprogs/tokentest.cpp: testprogs/tokentest.nw
	notangle -L -Rtokentest.cpp testprogs/tokentest.nw > testprogs/tokentest.cpp

clean:
	rm -f error.h error.cpp error.o
	rm -f token.h token.cpp token.o
	rm -f testprogs/tokentest.cpp testprogs/tokentest
	rm -f position.h
	rm -f code.tex code.pdf
