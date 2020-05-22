local DUIL = require "DUIL"
require "DUIL.components.animation"

local TransformAnimation = setmetatable({
	type="TransformAnimation",
	modes={
		linear="linear",
		quadin="quadin",
	}
}, DUIL.components.Animation)
TransformAnimation.__index = TransformAnimation
TransformAnimation.__tostring = DUIL.components.Animation.__tostring

---@param fromUiConstraints DUIL_UiConstraints
---@param toUiConstraints DUIL_UiConstraints
---@param transitionTime number @ In seconds
function TransformAnimation.new(fromUiConstraints, toUiConstraints, transitionTime, mode)
	assert(fromUiConstraints.type == DUIL.Constraints.UiConstraints.type, "fromUiConstraints is not a UiConstraints")
	assert(toUiConstraints.type == DUIL.Constraints.UiConstraints.type, "toUiConstraints is not a UiConstraints")
	local self = setmetatable({
		from=fromUiConstraints,
		to=toUiConstraints,
		time=transitionTime,
		mode=mode or "linear"
	}, TransformAnimation)
	self:setup()
	return self
end

---@param object DUIL_Object
function TransformAnimation:setupAnimation(object)
	local driver = DUIL.Constraints.UiConstraints.new()
	object:addDriver(driver)
	driver:setX(DUIL.Constraints.Pixel.new(0))
	driver:setY(DUIL.Constraints.Pixel.new(0))
	driver:setWidth(DUIL.Constraints.Pixel.new(0))
	driver:setHeight(DUIL.Constraints.Pixel.new(0))
	return {
		object=object,
		driver=driver,
		triggerPoint=DUIL.Utils.DeepCopy(driver),
		direction=false,  -- true mean going to `to`, false means going to `from`
		deltatime=0
	}
end

---@param object DUIL_Object
function TransformAnimation:cleanupAnimation(object, objectData)
	object:removeDriver(objectData.driver)
end

function TransformAnimation:triggerAnimation(objectData)
	self:_setDirection(objectData, not objectData.direction)
end
function TransformAnimation:setDirection(object, direction)
	self:_setDirection(self.objectData[object], direction)
end
function TransformAnimation:_setDirection(objectData, direction)
	objectData.triggerPoint = DUIL.Utils.DeepCopy(objectData.driver)
	objectData.direction = direction
	if objectData.direction then
		objectData.deltatime = 0
	else
		objectData.deltatime = self.time
	end
end

function TransformAnimation:updateAnimation(objectData, dt)
	local from ,to, dt01
	if objectData.direction then
		objectData.deltatime = DUIL.Utils.Clamp(objectData.deltatime + dt, 0, self.time)
		from = objectData.triggerPoint
		to = self.to
		dt01 = objectData.deltatime / self.time
	else
		objectData.deltatime = DUIL.Utils.Clamp(objectData.deltatime - dt, 0, self.time)
		from = objectData.triggerPoint
		to = self.from
		dt01 = 1 - objectData.deltatime / self.time
	end
	local x, y, w, h = 0, 0, 0, 0
	if self.mode == TransformAnimation.modes.quadin then
		x = DUIL.Utils.Quadin(to:getX(objectData.object), from:getX(objectData.object), 1-dt01)
		y = DUIL.Utils.Quadin(to:getY(objectData.object), from:getY(objectData.object), 1-dt01)
		w = DUIL.Utils.Quadin(to:getWidth(objectData.object), from:getWidth(objectData.object), 1-dt01)
		h = DUIL.Utils.Quadin(to:getHeight(objectData.object), from:getHeight(objectData.object), 1-dt01)
	else  -- linear
		x = DUIL.Utils.Lerp(from:getX(objectData.object), to:getX(objectData.object), dt01)
		y = DUIL.Utils.Lerp(from:getY(objectData.object), to:getY(objectData.object), dt01)
		w = DUIL.Utils.Lerp(from:getWidth(objectData.object), to:getWidth(objectData.object), dt01)
		h = DUIL.Utils.Lerp(from:getHeight(objectData.object), to:getHeight(objectData.object), dt01)
	end
	objectData.driver:setX(DUIL.Constraints.Pixel.new(x))
	objectData.driver:setY(DUIL.Constraints.Pixel.new(y))
	objectData.driver:setWidth(DUIL.Constraints.Pixel.new(w))
	objectData.driver:setHeight(DUIL.Constraints.Pixel.new(h))
end

DUIL.components.TransformAnimation = TransformAnimation -- Typing
DUIL.register(TransformAnimation)
