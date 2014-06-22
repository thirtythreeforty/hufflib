Hufflib is a Huffman compression/decompression library for [KnightOS](http://www.knightos.org/), a 3rd party OS for TI calculators.  It uses a 
precomputed Huffman tree due to the limitations of the TI platform (and because the data being compressed is usually much smaller than the stored tree would be). It achieves decent compression ratios with a reasonably fast decompression speed and constant memory usage (around 3 or 4 KB). More importantly, it can be targeted toward a specific type of data, such as code or text, to optimize compression ratios.

To build hufflib, you need to copy the repository to within the KnightOS `packages/` directory and rebuild KnightOS.  You could use Git submodules if you are a KnightOS developer.

Of course, hufflib is free software, released under the GNU LGPLv3 or later; its license can be found in `COPYING.hufflib`.  The generator script is licensed under the GPLv3 or later, its license is in `COPYING.gentree`.  Lastly, the precompiled KnightOS binaries are MIT licensed; their license is in the file `COPYING.binaries`.
