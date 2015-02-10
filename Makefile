.PHONY: clean

error.o: error.cpp error.h position.h
error.h: error.nw
	notangle -L -Rerror.h error.nw > error.h
error.cpp: error.nw
	notangle -L -Rerror.cpp error.nw > error.cpp
position.h: position.nw
	notangle -L -Rposition.h position.nw > position.h

clean:
	rm -f error.h error.cpp position.h
