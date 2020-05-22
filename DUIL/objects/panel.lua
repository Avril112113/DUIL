local DUIL = require "DUIL"
require "DUIL.objects.objectContent"

local Constraints = DUIL.Constraints


---@class DUIL_PanelObject
local Panel = setmetatable({
	type="Panel",
	contentObjectConstraints=Constraints.UiConstraints.new(
		Constraints.Pixel.new(3),
		Constraints.Pixel.new(3),
		Constraints.TargetMod.new("parent", Constraints.Percent.new(1)) - Constraints.ObjectRawX*2,
		Constraints.TargetMod.new("parent", Constraints.Percent.new(1)) - Constraints.ObjectRawY*2
	)
}, DUIL.Object)
Panel.__index = Panel
Panel.__tostring = DUIL.Object.__tostring

function Panel.new(objectClass, name)
	local self = DUIL.Object.new(objectClass, name)
	self.contentObject = DUIL.objects.ObjectContent:new()
	self.contentObject:setParent(self)
	self.contentObject:setConstraints(self.contentObjectConstraints)
	return self
end

function Panel:draw(depth)
	self:applyColor("background")
	love.graphics.rectangle("fill", 0, 0, self:getWidth(), self:getHeight())
	love.graphics.setLineWidth(3)
	self:applyColor("border")
	love.graphics.rectangle("line", 1, 1, self:getWidth()-2, self:getHeight()-2)

	DUIL.Object.draw(self, depth)
end

function Panel:addContent(object)
	object:setParent(self.contentObject)
end

DUIL.objects.Panel = Panel -- Typing
DUIL.register(Panel)
