local DUIL = require "DUIL"
require "DUIL.objects.objectContent"

local Constraints = DUIL.Constraints

---@class DUIL_CollapseableObject
local Collapseable = setmetatable({
	type="Collapseable",
	font=love.graphics.getFont(),
	buttonSize=16,
	collapsed=false
}, DUIL.Object)
Collapseable.__index = Collapseable
Collapseable.__tostring = DUIL.Object.__tostring

function Collapseable.new(objectClass, name)
	local self = DUIL.Object.new(objectClass, name)

	self.barObject = DUIL.objects.Panel:new("collapseableBar")
	self.barObject:setColor("background", self:getColor("primary"))
	self.barObject:setColor("border", DUIL.Color.fromRGBA(0, 0, 0, 0))
	self.barObject:setParent(self)
	self.barObject:setConstraints(Constraints.UiConstraints.new(
		Constraints.Zero,
		Constraints.Zero,
		Constraints.TargetMod.new("parent", Constraints.Percent.new(1)),
		Constraints.Get.new(function()
			return self.barObject.contentObject:getY() + self.textObject:getHeight() + self.barObject.contentObject:getY()
		end)
	))

	self.textObject = DUIL.objects.Text:new("collapseableText")
	self.barObject:addContent(self.textObject)
	self.textObject:setConstraints(Constraints.UiConstraints.new(
		self.barObject.contentObjectConstraints.x,
		Constraints.Zero,
		Constraints.TargetMod.new("parent", Constraints.Percent.new(1)) - Constraints.Get.new(function() return 3 + self.collapseButton:getWidth() end),
		Constraints.Get.new(function() return self.buttonSize end)
	))

	self.collapseButton = DUIL.Object:new("collapseButton")
	self.barObject:addContent(self.collapseButton)
	self.collapseButton:setConstraints(Constraints.UiConstraints.new(
		Constraints.TargetMod.new("parent", Constraints.ObjectWidth) - Constraints.ObjectWidth,
		Constraints.TargetMod.new("parent", Constraints.ObjectHeight/2) - Constraints.ObjectHeight/2,
		Constraints.Get.new(function() return self.buttonSize end),
		Constraints.Get.new(function() return self.buttonSize end)
	))
	function self.collapseButton.draw(buttonObject, depth)
		love.graphics.setLineWidth(3)
		buttonObject:applyColor("controlButtonColor")
		buttonObject:getSkin():draw("cross", buttonObject, 0, 0, buttonObject:getWidth(), buttonObject:getHeight())

		DUIL.Object.draw(buttonObject, depth)
	end
	self.collapseButton:addComponent(DUIL.components.Clicked.new(function()
		self:toggle()
	end))

	-- TODO: contentObject will probably be a list or something
	self.contentObject = DUIL.objects.ObjectContent:new()
	self.contentObject:setParent(self)
	self.contentObject:setConstraints(Constraints.UiConstraints.new(
		Constraints.Zero,
		Constraints.TargetMod.new(self.barObject, Constraints.ObjectY + Constraints.ObjectHeight),
		Constraints.TargetMod.new("parent", Constraints.Percent.new(1)),
		Constraints.TargetMod.new("parent", Constraints.Percent.new(1)) - Constraints.ObjectRawY
	))

	return self
end

function Collapseable:draw(depth)
	self:applyColor("background")
	love.graphics.rectangle("fill", 0, 0, self:getWidth(), self:getHeight())

	DUIL.Object.draw(self, depth)
end

function Collapseable:toggle()
	self.collapsed = not self.collapsed
	self.contentObject.hidden = self.collapsed
end

function Collapseable:getHeight()
	if self.collapsed then
		return self.barObject:getHeight() + 3
	else
		return DUIL.Object.getHeight(self)
	end
end

---@param object DUIL_Object
function Collapseable:addContent(object)
	object:setParent(self.contentObject)
end

---@param font Font
function Collapseable:setFont(font)
	self.font = font
end

---@param text string
function Collapseable:setText(text)
	self.textObject:setText(text)
end

DUIL.objects.Collapseable = Collapseable -- Typing
DUIL.register(Collapseable)
