Introduction:
-------------

This directory and it subdirectories contain my spl compiler and the test 
 infrastructure supporting it.

The implementation is entirely written in noweb, with c++ as the programming 
 language. This means that noweb is a build-time requirement since it is used 
 to extract all of the code for the compiler. Noweb is available as a package
 on ubuntu (package name: noweb), and can also be obtained at 
 https://www.cs.tufts.edu/~nr/noweb/. A package with pre-generated source files 
 (.c and .h) can be provided on request.

Building:
---------

The current edition does not contain the entire compiler, and thus only test
 programs can be build. A testprogram <program> can be build by issuing

	make testprogs/<program>

A suite with test input is provided in the tests/ directory tree. Running the
 test programs against these testcases can be done with

	make test

Since the source is noweb, it can be turned into a pdf. This requires a latex 
 distribution to be available on the system that provides at the least the
 packages amsmath, mathpartir, noweb, geometry, textcomp, hyperref and longtable. Also the 
 tool latexmk needs to be available, it is used to manage the build process.
 
The pdf of the main compiler code can be produced with

	make code.pdf

That for the test programs is available with

	make test.pdf
