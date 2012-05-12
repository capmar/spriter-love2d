
Spriter= {}

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

local function animSumDuration(anim)
	local sum= 0
	
	for i,frame in ipairs(anim) do
		sum= sum + frame.duration
	end

	return sum
end

local function animGetFrameIndex (anim, t)
	t= t % animSumDuration (anim)
	
	for i,frame in ipairs(anim) do
		if t < frame.duration then return i, t / frame.duration end
		t= t - frame.duration
	end
end

function Spriter.newAnim (keyframes)
	return {
		sumDuration= function() return animSumDuration (keyframes) end,
		getFrameIndex= function(t) return animGetFrameIndex (keyframes, t) end,
		getFrameName= function(i) return keyframes[i].name end,
		numFrames= function() return #keyframes end,
	}
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

local function frameDraw(frame, x, y, r, sx, sy, ox, oy)
	r= r or 0
	sx= sx or 1
	sy= sy or sx
	ox= ox or 0
	oy= oy or 0

	love.graphics.push()
	love.graphics.translate (x, y)
	love.graphics.rotate (r)
	love.graphics.scale (sx, sy)
	love.graphics.translate (-ox, -oy)

	for i,sprite in ipairs(frame) do
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

	love.graphics.pop()
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

local function frameMix (frame1, frame2, ratio)
	local sprites= {}

	for i,sprite1 in ipairs(frame1) do
		local sprite2= frame2.findSprite (sprite1.image)
		 sprites[i]= sprite2 and mixSprite (sprite1, sprite2, ratio) or sprite1
	end

	return Spriter.newFrame (sprites)
end

function Spriter.newFrame (sprites)
	return {
		draw= function(x, y, r, sx, sy, ox, oy) return frameDraw (sprites, x, y, r, sx, sy, ox, oy) end,
		findSprite= function(name) return findSprite(sprites, name) end,
		mix= function(frame2, ratio) return frameMix(sprites, frame2, ratio) end,
}
end

-- spriter

function Spriter.new (path)
	local animdata, framedata= love.filesystem.load(path)()

	return {
		getAnim= function(name) return animdata[name] end,
		getFrame= function(name) return framedata[name] end,
	}
end

return Spriter
