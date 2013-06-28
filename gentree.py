#!/usr/bin/env python3

#	gentree.py - generates a Huffman tree for use with hufflib.asm
#	Copyright (C) 2013  George Hilliard
#
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys

treeNonce = 0
class Tree:
	def __init__(self, c1 = None, c2 = None, byte = -1, weight = 0):
		global treeNonce
		self.child1 = c1
		self.child2 = c2
		if(self.child1 is not None):
			self.child1.parent = self
			self.child1.whichChild = 0
		if(self.child2 is not None):
			self.child2.parent = self
			self.child2.whichChild = 1
		self.parent = None
		self.whichChild = None
		self.weight = weight
		self.nonce = treeNonce
		treeNonce += 1
		self.byte = byte

	def Compressed(self):
		if self.parent is None:
			# Base case
			return ""
		s = self.parent.Compressed() + str(self.whichChild)
		if self.child1 is None and self.child2 is None:
			print(self.nonce, s, file=sys.stderr)
			# Split the string into bytes of 8 bits
			l = [s[i:i + 8] for i in range(len(s) // 8)]
			if len(s) % 8 != 0:
				l.append((s[-(len(s) % 8):] + "0000000")[0:8])

			# Build the output
			formatted = "\t.db " + hex(len(s)) + "\n"
			for byte in l:
				formatted += "\t.db 0b" + byte + "\n"
			return formatted
		else:
			return s

	def __str__(self):
		# Header
		s = "tree" + str(self.nonce) + ":\n"

		# Type
		treeType = 0
		if self.parent == None:
			treeType += 2
		if self.child1 == None and self.child2 == None:
			treeType += 1
		s += "\t.db " + bin(treeType) + "\n"

		# Data
		if self.child1 == None and self.child2 == None:
			s += "\t.db " + hex(self.byte) + "\n"
		else:
			s += "\t.dw tree" + str(self.child1.nonce) + ", tree" + str(self.child2.nonce) + "\n"
			s += str(self.child1) + str(self.child2)
		return s

	def __gt__(self, other):
		return self.weight > other.weight
	def __lt__(self, other):
		return self.weight < other.weight

def main():
	forest = [Tree(byte = i, weight = 0) for i in range(256)]

	ch = sys.stdin.buffer.read(1)
	while ch != b'':
		ch = ord(ch)
		forest[ch].weight += 1
		ch = sys.stdin.buffer.read(1)

	leaves = [leaf for leaf in forest]

	# Build the Huffman tree
	while len(forest) > 1:
		forest.sort()
		forest.append(Tree(c1 = forest[0], c2 = forest[1], weight = forest[0].weight + forest[1].weight))
		del forest[0:2]

	# Output the tree and leafTable
	print("tree:")
	print(forest[0])

	print("leafTable:")
	for i in range(256):
		print("\t.dw leaf" + str(i))

	for i in range(256):
		print("leaf" + str(i) + ":")
		print(leaves[i].Compressed())


main()
