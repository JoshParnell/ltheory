@echo off
setlocal

set OBJFOLDER=obj
set OUTFOLDER=bin
set OUTFILE=lt
set SRCPATH=src\*.cpp

set ARCH=32
set TYPE=executable
set CONSOLE=1

set ROOT=..
set EXTLIBS=libphx{b}{d}.lib
set EXTINCPATHS=%ROOT%\\shared\\include\\libphx

pushd %~pd0
call %ROOT%\\tool\\nbsbuild\\msvc14.bat %*
popd
