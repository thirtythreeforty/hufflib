Hufflib is a Huffman compression/decompression library for [KnightOS](http://www.knightsoft.org/), a 3rd party OS for TI calculators.  It uses a precomputed Huffman tree due to the limitations of the TI platform (and because the data being compressed is usually much smaller than the stored tree would be). It achieves decent compression ratios with a reasonably fast decompression speed and constant memory usage (around 3 or 4 KB). More importantly, it can be targeted toward a specific type of data, such as code or text, to optimize compression ratios.

To build the library, follow these steps:

The library uses a precomputed tree which can be generated with gentree.py.  First you must put some reference files into the sources/ directory; these are analyzed by the script to determine the optimal Huffman tree to use.  Good things to use are KnightOS userland binaries, a large text document, etc, depending upon the target data type.  (Sample data files will ultimately be distributed with hufflib.) Then, the simplest way to invoke the script is to simply run 

    make hufftree.asm

which will create hufftree.asm.

To build hufflib itself, you need to copy it to within the KnightOS source tree and rebuild KnightOS. (This is because KnightOS does not currently have an easy mechanism to incorporate 3rd party files; hopefully, this will be changed soon.)  Copy or link the specified files into their corresponding directories:
- hufflib.asm       packages/hufflib (you will have to create this directory)
- hufftree.asm      packages/hufflib
- hufflib.inc       inc/

Then, apply the patch makefile.patch to the main KnightOS Makefile (suitably change the path):

    git apply makefile.patch

and rebuild KnightOS with `make`.
