spriter-love2d
==============

Basic playback support for the 2D animation tool Spriter within the game framework love2d.

Quick start
-----------

Drag the project folder _spriter.love_ onto the love executable to launch the spriter demo. Use the arrow keys to move the demo character about. 

You may download the latest love executable for your platform from the love2d website: http://love2d.org/

Importing data
--------------

In order to avoid parsing XML files during runtime, you need to convert Spriter SCML files to lua data files ahead of time. You should use the included python script _scml2lua.py_ to convert files from Spriter to be read with spriter-love2d.

You may download the latest free beta version of Spriter from Brashmonkey's website: http://brashmonkey.com/spriter.htm

The following terminal command will convert the BetaFormatHero included with the Spriter beta to a lua data file:
	
	python scml2lua.py BetaFormatHero.SCML >> BetaFormatHero.SCML.lua

Basic usage
-----------

Include the file _spriter.lua_, your Spriter image folders and the converted SCML file in your own love2d project. Here is an outline of how to load and draw a frame of Spriter animation.

	local data= Spriter.new ('BetaFormatHero.lua')
	local anim= data.getAnim ('idle_healthy')
	local i= anim:getFrameIndex (tsec * 100)
	local frame= data.getFrame(anim:getFrameName (i))
	frame:draw()

spriter-love2d currently alway draws a Spriter frame at position (0, 0). You may use love2d's support for matrix manipulation to affect the draw rotation, scale and position.

	love.graphics.push()
	love.graphics.translate (x, y) --position character
	love.graphics.scale (-1, 1)	--flip character's x direction
	frame:draw()
	love.graphics.pop()

See the project file _main.lua_ for an example basic playback for Spriter.

Feedback
--------

Contact me at @mariocaprino for comments and feedback!


