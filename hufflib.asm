;	hufflib.asm - Huffman compression library for KnightOS
;	Copyright (C) 2013  George Hilliard
;
;	This program is free software: you can redistribute it and/or modify
;	it under the terms of the GNU Lesser General Public License as
;	published by the Free Software Foundation, either version 3 of the
;	License, or (at your option) any later version.
;
;	This program is distributed in the hope that it will be useful,
;	but WITHOUT ANY WARRANTY; without even the implied warranty of
;	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;	GNU Lesser General Public License for more details.
;
;	You should have received a copy of the GNU Leser General Public License
;	along with this program.  If not, see <http://www.gnu.org/licenses/>.

.nolist
libId .equ 0x60
#include "kernel.inc"
.list

.dw 0x0060 ; Library ID

.org 0

jumpTable:
    ret \ nop \ nop
    ret \ nop \ nop
    jp huff
    jp unhuff
    .db 0xFF

;; huff
;;  Compresses data using Huffman coding.
;;  The compressed data has a 3-byte header.  The
;;  first two bytes are the length of the uncompressed
;;  data.  The last byte is the index of the pre-stored
;;  Huffman tree to use.
;;  It might be advisable to RLE the data first.
;; Inputs:
;;  HL: Data to compress
;;  DE: Location of compressed data
;;  BC: Size of uncompressed data
;; Outputs:
;;  BC: Size of compressed data
huff:
	ret

;; unhuff
;;  Decompresses data using Huffman coding.
;; Inputs:
;;  HL: Data to decompress
;;  DE: Location for uncompressed data
unhuff:
	ret

#include "hufftree.asm"
