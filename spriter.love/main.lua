Spriter= require 'spriter'

local herospriter
local herodata= {
	x= 400,
	dir= 1,
	t= love.timer.getTime(),
}

--

local function draw (anim, t)
	local i= anim:getFrameIndex (t * 100)
	local frame= herospriter.getFrame(anim:getFrameName (i))

	love.graphics.push()
	love.graphics.translate (herodata.x, 500)
	love.graphics.scale (herodata.dir, 1)
	frame:draw()
	love.graphics.pop()
end

local function drawTween (anim, t)
	local i, ratio= anim:getFrameIndex (t * 100)
	local j= i + 1
	if #anim < j then j= 1 end
	
	local frame1= herospriter.getFrame(anim:getFrameName (i))
	local frame2= herospriter.getFrame(anim:getFrameName (j))
	local frame= frame1:mix (frame2, ratio)

	love.graphics.push()
	love.graphics.translate (herodata.x, 500)
	love.graphics.scale (herodata.dir, 1)
	frame:draw()
	love.graphics.pop()
end

--

local function inputDir()
	if love.keyboard.isDown ('left') then
		return -1
	elseif love.keyboard.isDown ('right') then
		return 1
	else
		return 0
	end
end

local idle

local function walk()
	local dir= inputDir()
	local t= love.timer.getTime()

	if dir == 0 then
		herodata.t= t
		love.draw= idle
		love.draw()
		return
	end

	herodata.dir= dir
	herodata.x= herodata.x + 4 * dir

	local anim= herospriter.getAnim ('walk')
	draw (anim, t - herodata.t)
end

function idle()
	local dir= inputDir()
	local t= love.timer.getTime()

	if dir ~= 0 then
		herodata.t= t
		love.draw= walk
		love.draw()
		return
	end

	local anim= herospriter.getAnim ('idle_healthy')
	draw (anim, t - herodata.t)
end

--

function love.load()
	herospriter= Spriter.new ('BetaFormatHero.lua')
end

love.draw= idle
