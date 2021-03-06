OUTDIR:=bin/
LIBDIR:=$(OUTDIR)lib/
INCDIR:=$(OUTDIR)include/
ETCDIR:=$(OUTDIR)etc/

all: package

package: $(LIBDIR)huff $(INCDIR)hufflib.inc
	kpack hufflib-0.1.0.pkg $(OUTDIR)

$(LIBDIR)huff: hufftree.asm hufflib.asm
	mkdir -p $(LIBDIR)
	$(AS) $(ASFLAGS) --define "$(PLATFORM)" --include "$(INCLUDE);$(PACKAGEPATH)/hufflib/" hufflib.asm $(LIBDIR)huff

hufftree.asm: sources/* gentree.py
	cat sources/* | python3 gentree.py > hufftree.asm

$(INCDIR)hufflib.inc:
	mkdir -p $(INCDIR)
	cp hufflib.inc $(INCDIR)hufflib.inc

clean:
	rm -rf $(OUTDIR) hufftree.asm
	rm -rf hufflib-0.1.0.pkg

install: package
	kpack -e -s hufflib-0.1.0.pkg $(PREFIX)

.PHONY: all clean
