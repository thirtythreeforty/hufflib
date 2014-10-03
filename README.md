Hufflib
=======

Hufflib is a Huffman compression/decompression library for [KnightOS](http://www.knightos.org/), a 3rd party OS for TI calculators.
It allows onboard compression and decompression, achieving better compression than the kernel-provided RLE library.
It uses a precomputed Huffman tree due to the limitations of the TI platform (and because the data being compressed is usually much smaller than the stored tree would be).
Hufflib achieves decent compression ratios with a reasonably fast decompression speed and constant memory usage (around 3 or 4 KB).
More importantly, it can be targeted toward a specific type of data, such as code or text, to optimize compression ratios.

Building
--------

To build hufflib, you need to copy the repository to within the KnightOS `packages/` directory and rebuild KnightOS.
It will be automatically packaged by the KnightOS package system, and a package will be emitted in the build directory.

Licensing
---------
Of course, hufflib is free software, released under the GNU LGPLv3 or later; its license can be found in `COPYING.hufflib`.
The generator script is licensed under the GPLv3 or later, its license is in `COPYING.gentree`.
Lastly, the precompiled KnightOS binaries are MIT licensed; their license is in the file `COPYING.binaries`.
