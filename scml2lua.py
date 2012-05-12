#!/usr/bin/env python

import xml.sax
import sys

tags_value= ('name', 'duration', 'image', 'color', 'opacity', 'angle', 'xflip', 'yflip', 'width', 'height', 'x', 'y')
tags_dict= ('char', 'anim', 'frame')

def printAnimFrame(d):
	print "{name='%s', duration=%s}," % (d['name'], d['duration']);

def printSprite(d):
	image= d['image'].replace ('\\', '\\\\')
	print "{ image= '%s', color= %s, opacity= %s, angle= %s, xflip= %s, yflip= %s, width= %s, height= %s, x= %s, y= %s }," % (image, d['color'], d['opacity'], d['angle'], d['xflip'], d['yflip'], d['width'], d['height'], d['x'], d['y'])

def isAnim (arr):
	return arr[-1]  == 'anim'

def isFrame (arr):
	return arr[-1] == 'frame' and arr[-2] == 'spriterdata'

class SaxHandler (xml.sax.handler.ContentHandler):
	def __init__ (self):
		self.tags= []
		self.dict= None
		self.charlist= None

	def startElement (self, name, attrs):
		self.tags.append (name)
		if name == 'char':
			print 'return { --char'

		if name in tags_dict:
			self.dict= {}
		elif name in tags_value:
			self.charlist= []

	def endElement (self, name):
		self.tags.pop()
		if name == 'char':
			print '},'
			print
			print '{ --frames'
		elif name == 'spriterdata':
			print '}'

		if name == 'frame' and self.tags[-1] == 'anim':
			printAnimFrame (self.dict)
		elif name == 'sprite':
			printSprite (self.dict)
		elif name == 'anim' or (name == 'frame' and self.tags[-1] == 'spriterdata'):
			print '},'
		elif name in tags_value:
			value= ''.join (self.charlist)
			self.charlist= None

			if self.dict is not None:
				self.dict[name]= value

			if name == 'name' and isAnim (self.tags):
				print "%s= Spriter.newAnim{" % (value)
			elif name == 'name' and isFrame (self.tags):
				print "%s= Spriter.newFrame{" % (value)

	def characters (self, ch):
		if self.charlist is not None:
			self.charlist.append (ch)

#---


def main (inpath):
	handler= SaxHandler()
	xml.sax.parse (inpath, handler)

if __name__ == '__main__':
	path= sys.argv[1]
	main (path)
