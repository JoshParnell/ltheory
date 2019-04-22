NPROC := $(shell nproc)
NJOBS := $(shell echo $$(( $(NPROC) * 2 )))
MAKEFLAGS = -j$(NJOBS)

CC := clang++
LINK := clang++
PROJECT := lt

SRCPATH := src
OBJPATH := ./obj
OUTDIR  := ./bin
OUTFILE := $(PROJECT)64
OUTPATH := $(OUTDIR)/$(OUTFILE)

SOURCES := $(shell find $(SRCPATH)/ -type f -name '*.cpp')
OBJECTS := $(patsubst $(SRCPATH)/%.cpp, $(OBJPATH)/%.o, $(SOURCES))
DEPENDS := $(patsubst $(SRCPATH)/%.cpp, $(OBJPATH)/%.d, $(SOURCES))

LIBS := -lGL
LIBS += -lGLEW
LIBS += -ldl
LIBS += -lfreetype
LIBS += -lluajit-5.1
LIBS += -lphx64
LIBS += `sdl2-config --libs`

CFLAGS = `sdl2-config --cflags`
CFLAGS += -Wall -Wformat
CFLAGS += -fno-exceptions
CFLAGS += -ffast-math
CFLAGS += -O3 -msse -msse2 -msse3 -msse4
CFLAGS += -DDEBUG=0
CFLAGS += -g
CFLAGS += -Ilibphx/include/
CFLAGS += -Ilibphx/ext/
CFLAGS += -std=c++11
CFLAGS += -Wno-unused-variable

all: $(OUTPATH)
	@echo Build complete.

clean:
	rm -f $(OUTPATH)
	rm -rf $(OBJPATH)
	rm -rf log

debug: $(OUTPATH)
	@gdb $(OUTPATH)

run: $(OUTPATH)
	$(OUTPATH)

$(OUTPATH): $(OBJECTS)
	@mkdir -p $(OUTDIR)
	@echo [LINK] $(OUTPATH)
	@$(LINK) -o $(OUTPATH) $(OBJECTS) $(CFLAGS) $(LIBS)

$(OBJPATH)/%.o: $(SRCPATH)/%.cpp
	@mkdir -p $(OBJPATH)
	@echo [CC] $<
	@$(CC) -MD -MP $(CFLAGS) -o $@ -c $<

-include $(DEPENDS)
