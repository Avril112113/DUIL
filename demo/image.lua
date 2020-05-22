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
	Constraints.Pixel.new(325)
))

local image = DUIL.objects.Image:new("image")
mainPanel:addContent(image)
image:setConstraints(Constraints.UiConstraints.new(
	Constraints.Zero,
	Constraints.Zero,
	Constraints.TargetMod.new("parent", Constraints.Percent.new(1)),
	Constraints.TargetMod.new("parent", Constraints.Percent.new(0.75))
))
image:setImage(love.graphics.newImage("demo/image.jpg"))

local noImage = DUIL.objects.Image:new("noImage")
mainPanel:addContent(noImage)
noImage:setConstraints(Constraints.UiConstraints.new(
	Constraints.Zero,
	Constraints.TargetMod.new(image, Constraints.ObjectRawY + Constraints.ObjectRawHeight) + Constraints.Pixel.new(5),
	Constraints.TargetMod.new("parent", Constraints.Percent.new(1)),
	Constraints.TargetMod.new("parent", Constraints.Percent.new(1)) - Constraints.TargetMod.new(image, Constraints.ObjectRawY + Constraints.ObjectRawHeight) - Constraints.Pixel.new(5)
))

return mainPanel
