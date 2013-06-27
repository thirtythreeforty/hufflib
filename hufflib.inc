;	hufflib.inc - Include file for Huffman compression library for KnightOS
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

.macro hufflib(addr)
    lcall(hufflibId, addr)
.endmacro
.macro hufflib(cc, addr)
    lcall(hufflibId, cc, addr)
.endmacro

hufflibId .equ 0x60

; Routines
huff .equ 6
unhuff .equ 9
