print()

local DUIL = require "DUIL"
local Constraints = DUIL.Constraints


local BackgroundCellSize = 50
local background

local UiRoot = require "demo.root"
-- local animationPanel = require "demo.animation"
-- local textPanel = require "demo.text"
-- local imagePanel = require "demo.image"
local collapseablePanel = require "demo.collapseable"

local function genBackgroundImage()
	local imgData = love.image.newImageData(love.graphics.getWidth()+BackgroundCellSize, love.graphics.getHeight()+BackgroundCellSize)
	local mapCells = function(x, y, r, g, b, a)
		if (x+1)%BackgroundCellSize <= 0 or (y+1)%BackgroundCellSize <= 0 then
			return 0.7, 0.7, 0.7, 1
		else
			return 0, 0, 0, 0
		end
	end
	imgData:mapPixel(mapCells)
	background = love.graphics.newImage(imgData)
end


function love.draw()
	if background == nil then
		genBackgroundImage()
	end
	love.graphics.setColor(1, 0.5, 0.5, 1)
	love.graphics.draw(background, 0, 0)

	love.graphics.setColor(1, 1, 1, 1)
	DUIL.draw(UiRoot)

	-- love.graphics.setColor(1, 0, 0.5, 1)
	-- love.graphics.draw(background, 0, 0)

	DUIL.drawDebug(UiRoot, love.mouse.getX(), love.mouse.getY())
	love.graphics.setColor(1, 1, 1, 1)
	local fpsStr = "FPS: " .. love.timer.getFPS()
	love.graphics.print(fpsStr, love.graphics.getWidth()-love.graphics.getFont():getWidth(fpsStr), 0)
end

function love.update(dt)
	DUIL.update(UiRoot, dt)
end

function love.mousemoved(x, y, dx, dy, istouch)
	DUIL.mousemoved(UiRoot, x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button)
	DUIL.mousepressed(UiRoot, x, y, button)
end

function love.mousereleased(x, y, button)
	DUIL.mousereleased(UiRoot, x, y, button)
end

function love.keypressed(key, isrepeat)
	DUIL.keypressed(UiRoot, key, isrepeat)
end

function love.keyreleased(key)
	DUIL.keyreleased(UiRoot, key)
end

function love.resize(w, h)
	background = nil
end

