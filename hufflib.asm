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
    jp setUpOffsets
    ret \ nop \ nop
    jp huff
    jp unhuff
    .db 0xFF

setUpOffsets:
	push ix
	push hl
	push de
	icall(_)
_:	pop ix
	call memSeekToStart
	push ix \ pop de
	ild(hl, offsetNeeded2)
	ld (hl), e
	inc hl
	ld (hl), d
	pop de
	pop hl
	pop ix
	ret

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
	push af
	push hl
	push bc
	push ix
	push de
	push de
		; Set up state
		ld c, (hl)			; Uncompressed data size, into BC
		inc hl
		ld b, (hl)
		inc hl
		inc hl				; (skip) Huffman tree to use, not yet implemented
		ld d, (hl)			; First byte of data into D, TODO jump to correct location or something
		inc hl
		ld e, 0xFF			; Mask into E
.reroot:
		ild(ix, tree)		; Root of tree into IX

		; Check to ensure bytes are left
.nextBit:
		ld a, b \ or c \ jr z, .done

		; Get a bit
		sla d
		push af
			srl e
			jr nz, _
			ld d, (hl)
			inc hl
			ld e, 0xFF
_:		pop af

		; Shift to the correct location in the node
		jr nc, _
		inc ix
		inc ix
_:		push hl
			ld l, (ix + 3)
			ld h, (ix + 4)
			push de
offsetNeeded2 .equ $ + 1
				ld de, 0x0000
				add hl, de
			pop de
			ex (sp), hl
		pop ix
		; Determine if we've reached a leaf
		bit 0, (ix)
		jr z, .nextBit

		; Leaf!  Handle it.
		ld a, (ix + 3)
		ex (sp), hl
		ld (hl), a
		inc hl
		ex (sp), hl
		dec bc
		jr .reroot

.done:
	pop de
	pop de
	pop ix
	pop bc
	pop hl
	pop af
	ret

#include "hufftree.asm"
