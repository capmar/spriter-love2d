
--- image data

local imagedata= {}

local function getImage (name)
	local img= imagedata[name]
	if not img then
		local path= string.gsub(name, '\\', '/')
		img= love.graphics.newImage(path)
		imagedata[name]= img
	end

	return img
end

-- anim

local Anim= {}

function Anim.sumDuration(self)
	local sum= 0
	
	for i,frame in ipairs(self) do
		sum= sum + frame.duration
	end

	return sum
end

function Anim.getFrameIndex (self, t)
	t= t % Anim.sumDuration (self)
	
	for i,frame in ipairs(self) do
		if t < frame.duration then return i, t / frame.duration end
		t= t - frame.duration
	end
end

--- frame

local function parseColor (c)
	local b= c % 256
	c= math.floor(c / 256)
	local g= c % 256
	c= math.floor(c / 256)
	local r= c

	return r, g, b
end

local function makeColor (r, g, b)
	local c= r
	c= c * 256 + g
	c= c * 256 + b

	return c
end

local Frame= {}

function Frame.draw(self)
	
	for i,sprite in ipairs(self) do
		local r, g, b= parseColor (sprite.color)
		local a= (sprite.opacity / 100) * 255
		love.graphics.setColor (r, g, b, a)

		local img= getImage(sprite.image)
		local angle= math.rad (-sprite.angle)
		local scalex= sprite.width / img:getWidth()
		local scaley= sprite.height / img:getHeight()
		if sprite.flipx then scalex= -scalex end
		if sprite.flipy then scaley= -scaley end

		love.graphics.draw (img, sprite.x, sprite.y, angle, scalex, scaley)
	end
end

-- tweening

local function mix (a, b, ratio)
	return a * (1 - ratio) + b * ratio
end

local function shortestAngle (from, to)
	from= from % 360
	to= to % 360

	local angle= to - from
	if 180 < angle then
		angle= angle - 360
	elseif angle < -180 then
		angle= angle + 360
	end

	return angle
end

local function mixSprite (a, b, ratio)
	local r1, g1, b1= parseColor (a.color)
	local r2, g2, b2= parseColor (b.color)
	local red= math.floor(mix (r1, r2, ratio))
	local green= math.floor(mix (g1, g2, ratio))
	local blue= math.floor(mix (b1, b2, ratio))
	local angle= shortestAngle (a.angle, b.angle)

	return {
		image= a.image,
		color= makeColor (red, green, blue),
		opacity= mix (a.opacity, b.opacity, ratio),
		angle= mix (a.angle, a.angle + angle, ratio),
		xflip= a.xflip,
		yflip= a.yflip,
		width= mix (a.width, b.width, ratio),
		height= mix (a.height, b.height, ratio),
		x= mix (a.x, b.x, ratio),
		y= mix (a.y, b.y, ratio),
	}
end

local function findSprite (frame, image)
	
	for i,sprite in ipairs(frame) do
		if sprite.image == image then return sprite end
	end
end

function Frame.mix (frame1, frame2, ratio)
	dest= {
		draw= Frame.draw,
		mix= Frame.mix,
	}

	for i,sprite1 in ipairs(frame1) do
		local sprite2= findSprite (frame2, sprite1.image)
		dest[i]= sprite2 and mixSprite (sprite1, sprite2, ratio) or sprite1
	end

	return dest
end

-- spriter

local spriter= {}
char= nil
frames= nil

function spriter.new (path)
	local animdata, framedata;
	char= function(dict) animdata= dict end
	frames= function(dict) framedata= dict end

	love.filesystem.load(path)()

	for k,anim in pairs(animdata) do
		anim.sumDuration= Anim.sumDuration
		anim.getFrameIndex= Anim.getFrameIndex
		anim.getFrameName= function(self, i) return self[i].name end
	end

	for k,frame in pairs(framedata) do
		frame.draw= Frame.draw
		frame.mix= Frame.mix
	end

	return {
		getAnim= function(name) return animdata[name] end,
		getFrame= function(name) return framedata[name] end,
	}
end

return spriter