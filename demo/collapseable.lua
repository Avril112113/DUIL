local DUIL = require "DUIL"
local Constraints = DUIL.Constraints

local UiRoot = require "demo.root"


---@type DUIL_PanelObject
local mainPanel = DUIL.objects.Panel:new("mainPanel")
mainPanel:setParent(UiRoot)
mainPanel:setConstraints(Constraints.UiConstraints.new(
	Constraints.TargetMod.new("parent", Constraints.Percent.new(0.5)) - Constraints.ObjectWidth / 2,
	Constraints.TargetMod.new("parent", Constraints.Percent.new(0.5)) - Constraints.ObjectWidth / 2,
	Constraints.Pixel.new(350),
	Constraints.Pixel.new(400)
))

local collapseable = DUIL.objects.Collapseable:new("collapseable")
mainPanel:addContent(collapseable)
collapseable:setConstraints(Constraints.UiConstraints.new(
	Constraints.Zero,
	Constraints.Zero,
	Constraints.TargetMod.new("parent", Constraints.Percent.new(1)),
	Constraints.TargetMod.new("parent", Constraints.Percent.new(1))
))
collapseable:setText("Testing collapseable text...")

return mainPanel
