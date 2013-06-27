all: hufftree.asm

hufftree.asm: sources/* gentree.py
	cat sources/* | python3 gentree.py > hufftree.asm

clean:
	rm -f hufftree.asm
