local DUIL = require "DUIL"
require "DUIL.components.animation"

local ColorAnimation = setmetatable({
	type="ColorAnimation",
	modes={
		linear="linear",
		quadin="quadin",
	}
}, DUIL.components.Animation)
ColorAnimation.__index = ColorAnimation
ColorAnimation.__tostring = DUIL.components.Animation.__tostring

---@param fromColor DUIL_Color
---@param toColor DUIL_Color
---@param transitionTime number @ In seconds
function ColorAnimation.new(id, fromColor, toColor, transitionTime, mode)
	assert(fromColor.type == DUIL.Color.type, "fromColor is not a Color")
	assert(toColor.type == DUIL.Color.type, "toColor is not a Color")
	local self = setmetatable({
		id=id,
		from=fromColor,
		to=toColor,
		time=transitionTime,
		mode=mode or "linear"
	}, ColorAnimation)
	self:setup()
	return self
end

---@param object DUIL_Object
function ColorAnimation:setupAnimation(object)
	local driver = DUIL.ColorDriver.new(self.id, DUIL.Color.fromRGBA(self.from.r, self.from.g, self.from.b, self.from.a))
	object:addDriver(driver)
	return {
		object=object,
		driver=driver,
		triggerColor=DUIL.Utils.DeepCopy(driver.color),
		direction=false,  -- true mean going to `to`, false means going to `from`
		deltatime=0
	}
end

---@param object DUIL_Object
function ColorAnimation:cleanupAnimation(object, objectData)
	object:removeDriver(objectData.driver)
end

function ColorAnimation:triggerAnimation(objectData)
	self:_setDirection(objectData, not objectData.direction)
end
function ColorAnimation:setDirection(object, direction)
	self:_setDirection(self.objectData[object], direction)
end
function ColorAnimation:_setDirection(objectData, direction)
	objectData.triggerColor = DUIL.Utils.DeepCopy(objectData.driver)
	objectData.direction = direction
	if objectData.direction then
		objectData.deltatime = 0
	else
		objectData.deltatime = self.time
	end
end

function ColorAnimation:updateAnimation(objectData, dt)
	local from, to, dt01
	local pdt = objectData.deltatime
	if objectData.direction then
		objectData.deltatime = DUIL.Utils.Clamp(objectData.deltatime + dt, 0, self.time)
		from = objectData.triggerColor
		to = self.to
		dt01 = objectData.deltatime / self.time
	else
		objectData.deltatime = DUIL.Utils.Clamp(objectData.deltatime - dt, 0, self.time)
		from = objectData.triggerColor
		to = self.from
		dt01 = 1 - objectData.deltatime / self.time
	end
	local r, g, b, a = 0, 0, 0, 1
	if self.mode == ColorAnimation.modes.quadin then
		r = DUIL.Utils.Quadin(to.r, from.r, 1-dt01)
		g = DUIL.Utils.Quadin(to.g, from.g, 1-dt01)
		b = DUIL.Utils.Quadin(to.b, from.b, 1-dt01)
		a = DUIL.Utils.Quadin(to.a, from.a, 1-dt01)
	else  -- linear
		r = DUIL.Utils.Lerp(from.r, to.r, dt01)
		g = DUIL.Utils.Lerp(from.g, to.g, dt01)
		b = DUIL.Utils.Lerp(from.b, to.b, dt01)
		a = DUIL.Utils.Lerp(from.a, to.a, dt01)
	end
	local color = objectData.driver.color
	color.r = r
	color.g = g
	color.b = b
	color.a = a
end

DUIL.components.ColorAnimation = ColorAnimation -- Typing
DUIL.register(ColorAnimation)
