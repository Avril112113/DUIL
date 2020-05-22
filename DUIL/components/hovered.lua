local DUIL = require "DUIL"


---@class DUIL_HoveredComponent : DUIL_Component
local Hovered = setmetatable({
	type="Hovered"
}, DUIL.Component)
Hovered.__index = Hovered
Hovered.__tostring = DUIL.Component.__tostring

function Hovered.new(callback)
	assert(type(callback) == "function")
	return setmetatable({
		callback=callback,
		lastState=nil
	}, Hovered)
end

function Hovered:update(object, dt)
	local x, y = love.mouse.getX() - object:getXFromRoot(), love.mouse.getY() - object:getYFromRoot()
	local state = x >= 0 and y >= 0 and x <= object:getWidth() and y <= object:getHeight()
	if self.lastState ~= state then
		self.callback(object, state)
		self.lastState = state
	end
end

-- function Hovered:mousemoved(object, x, y, dx, dy, istouch)
-- 	local state = x >= 0 and y >= 0 and x <= object:getWidth() and y <= object:getHeight()
-- 	if self.lastState ~= state then
-- 		self.callback(object, state)
-- 		self.lastState = state
-- 	end
-- end

DUIL.components.Hovered = Hovered -- Typing
DUIL.register(Hovered)
