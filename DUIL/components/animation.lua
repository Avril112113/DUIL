local DUIL = require "DUIL"


---@class DUIL_AnimationComponent : DUIL_Component
--- NOTE: this is a base component
local Animation = setmetatable({
	type="Animation",
	---@type table<DUIL_Object, any>
	objectData=nil
}, DUIL.Component)
Animation.__index = Animation
Animation.__tostring = DUIL.Component.__tostring

function Animation:setup()
	self.objectData = {}
end

---@param object DUIL_Object
function Animation:setupAnimation(object)
end
---@param object DUIL_Object
function Animation:cleanupAnimation(object, objectData)
end
function Animation:triggerAnimation(objectData)
end
function Animation:updateAnimation(objectData, dt)
end

function Animation:trigger(object)
	assert(self.objectData[object] ~= nil, "Can not trigger animation for an object that does not have this animation component")
	self:triggerAnimation(self.objectData[object])
end
function Animation:reset(object)
	assert(self.objectData[object] ~= nil, "Can not reset animation state for an object that does not have this animation component")
	self:cleanupAnimation(object, self.objectData[object])
	self.objectData[object] = self:setupAnimation(object)
end
function Animation:update(object, dt)
	assert(self.objectData[object] ~= nil, "Can not update animation for an object that does not have this animation component")
	self:updateAnimation(self.objectData[object], dt)
end
function Animation:added(object)
	self.objectData[object] = self:setupAnimation(object)
end
function Animation:removed(object)
	self:cleanupAnimation(object, self.objectData[object])
	self.objectData[object] = nil
end

DUIL.components.Animation = Animation -- Typing
DUIL.register(Animation)
