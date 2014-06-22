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
    jp huffCalculateCompressedSize
    .db 0xFF

setUpOffsets:
	push ix
	push hl
	push de
	icall(_)
_:	pop ix
	pcall(memSeekToStart)
	push ix \ pop de
	ild(hl, offsetNeeded1)
	ld (hl), e
	inc hl
	ld (hl), d
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
;;  BC: Size of compressed data, including header
huff:
	push af
	push ix
	push hl
	push de
		; Store header
		ex de, hl
		ld (hl), c \ inc hl \ ld (hl), b \ inc hl
		ld (hl), 0 \ inc hl	; Tree choosing not implemented
		ex de, hl
		push de
			; Set up compression state
			ld de, 0x00FF
.nextByte:
			; Check to ensure bytes are left, from BC
			ld a, b \ or c \ jr z, .done

			icall(gotoByteEntry)

		  ex (sp), hl				; destination into HL
			push bc
				ld b, (ix)			; Number of bits in Huffman form of byte
				inc b				; Account for djnz after jumping to .start
				jr .start
_:				rlca
				rl d

				srl e
				jr nz, _
				; Store a byte
				ld (hl), d
				inc hl
				ld de, 0x00FF

_:				srl c
				jr nz, _
.start:
				; Read next byte from table
				ld a, (ix + 1)
				inc ix
				ld c, 0xFF

_:				djnz ---_
			pop bc
		  ex (sp), hl	; destination onto stack
			jr .nextByte

.done:
		; Store last partial byte, padded with zeros
		pop hl
		ld a, e
		cp 0xFF			; Don't want to store a whole extra byte!  It would be wrong.
		jr z, ++_
_:		sla d
		srl e
		jr nz, -_
		ld (hl), d
		inc hl

	; Calculate compressed data's size, into BC
_:	pop de
	xor a
	sbc hl, de
  ex (sp), hl
	pop bc
	pop ix
	pop af
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
		ld a, b \ or c \ jr z, .done

.nextBit:
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
			ld l, (ix + 1)
			ld h, (ix + 2)
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
		ld a, (ix + 1)
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

;; huffCalculateCompressedSize
;;  Calculates the size of data resulting from a Huffman
;;  compression, but does not perform any compression.
;;  Note: a companion routine is not supplied for
;;  decompressed size calculation; that information is
;;  stored in the header of a compressed block.
;; Inputs:
;;  HL: Data to compress
;;  BC: Size of uncompressed data
;; Outputs:
;;  BC: Size of compressed data
huffCalculateCompressedSize:
	push af
	push ix
	push hl
	push de
		ld e, 0					; High word of dword size in bits
		push de					; (don't actually care about high byte)
			ld de, 24			; Size of header in bits (low word of dword)
.nextByte:
			; Check to ensure bytes are left, from BC
			ld a, b \ or c \ jr z, .done

			icall(gotoByteEntry)

			xor a
			push hl				; Add number of bits to low word
				ex de, hl
				ld e, (ix)
				ld d, a
				add hl, de
				ex de, hl
			pop hl
		  ex (sp), hl			; High word into HL
			adc a, l
			ld l, a
		  ex (sp), hl
			jr .nextByte
.done:
		pop hl
		; Divide LDE by 8, add 1 if there is a remainder
		xor a
		srl l \ rr d \ rr e \ rla
		srl l \ rr d \ rr e \ rla
		srl l \ rr d \ rr e \ rla
		or a \ jr z, $ + 3 \ inc de
		push de \ pop bc
	pop de
	pop hl
	pop ix
	pop af
	ret

; gotoByteEntry: Helper routine for compressor and calculator.
; Gets a byte from HL, increments HL, decrements BC, and sets
; IX to the address of the byte's leaf entry.  Destroys AF.
gotoByteEntry:
	push hl
		; Get a byte
		ld l, (hl)
		dec bc

		; Calculate offset in leaf table, into IX
		xor a \ sla l \ rla \ ld h, a
		push de
			ild(de, leafTable)
			add hl, de
		pop de
		ex (sp), hl
	pop ix
	inc hl

	; (IX) + offset -> IX
	push hl
		ld l, (ix + 0)
		ld h, (ix + 1)
		push de
offsetNeeded1 .equ $ + 1
			ld de, 0x0000
			add hl, de
		pop de
		ex (sp), hl
	pop ix
	ret

.echo "Size of hufflib routines: {0} bytes" $

#include "hufftree.asm"
