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
-- print(tostring(mainPanel))

---@type DUIL_PanelObject
local buttonSlideLinear = DUIL.objects.Panel:new("buttonSlideLinear")
mainPanel:addContent(buttonSlideLinear)
buttonSlideLinear:setConstraints(Constraints.UiConstraints.new(
	Constraints.Pixel.new(5),
	Constraints.Pixel.new(5),
	Constraints.Pixel.new(200),
	Constraints.Aspect.new(0.25)
))
local buttonSlideLinearAnim = DUIL.components.TransformAnimation.new(
	Constraints.UiConstraints.new(
		Constraints.Zero,
		Constraints.Zero,
		Constraints.Zero,
		Constraints.Zero
	),
	Constraints.UiConstraints.new(
		Constraints.TargetMod.new("parent", Constraints.ObjectWidth) - Constraints.ObjectRawWidth - Constraints.ObjectRawX*2,
		Constraints.Zero,
		Constraints.Zero,
		Constraints.Zero
	),
	1, DUIL.components.TransformAnimation.modes.linear
)
buttonSlideLinear:addComponent(buttonSlideLinearAnim)
buttonSlideLinear:addComponent(DUIL.components.Clicked.new(function(object, x, y, button)
	buttonSlideLinearAnim:trigger(object)
end))
local buttonColorLinearAnim = DUIL.components.ColorAnimation.new(
	nil,
	DUIL.Color.fromRGBA(0, 0, 0, 0),
	DUIL.Color.fromRGBA(0.1, -0.1, -0.1, 0),
	0.1, DUIL.components.TransformAnimation.modes.linear
)
buttonSlideLinear:addComponent(buttonColorLinearAnim)
buttonSlideLinear:addComponent(DUIL.components.Hovered.new(function(object, enter)
	buttonColorLinearAnim:setDirection(object, enter)
end))

---@type DUIL_PanelObject
local buttonSlideQuadin = DUIL.objects.Panel:new("buttonSlideQuadin")
mainPanel:addContent(buttonSlideQuadin)
buttonSlideQuadin:setConstraints(Constraints.UiConstraints.new(
	Constraints.TargetMod.new(buttonSlideLinear, Constraints.ObjectRawX),
	Constraints.TargetMod.new(buttonSlideLinear, Constraints.ObjectRawY) + Constraints.TargetMod.new(buttonSlideLinear, Constraints.ObjectHeight) + Constraints.Pixel.new(20),
	Constraints.Pixel.new(200),
	Constraints.Aspect.new(0.25)
))
local buttonSlideQuadinAnim = DUIL.components.TransformAnimation.new(
	Constraints.UiConstraints.new(
		Constraints.Zero,
		Constraints.Zero,
		Constraints.Zero,
		Constraints.Zero
	),
	Constraints.UiConstraints.new(
		Constraints.TargetMod.new("parent", Constraints.ObjectWidth) - Constraints.ObjectRawWidth - Constraints.ObjectRawX*2,
		Constraints.Zero,
		Constraints.Zero,
		Constraints.Zero
	),
	1, DUIL.components.TransformAnimation.modes.quadin
)
buttonSlideQuadin:addComponent(buttonSlideQuadinAnim)
buttonSlideQuadin:addComponent(DUIL.components.Clicked.new(function(object, x, y, button)
	buttonSlideLinearAnim:trigger(buttonSlideLinear)
	buttonSlideQuadinAnim:trigger(buttonSlideQuadin)
end))
local buttonColorQuadinAnim = DUIL.components.ColorAnimation.new(
	nil,
	DUIL.Color.fromRGBA(0, 0, 0, 0),
	DUIL.Color.fromRGBA(-0.75, 0.75, -0.75, 0),
	1, DUIL.components.TransformAnimation.modes.quadin
)
buttonSlideQuadin:addComponent(buttonColorQuadinAnim)
buttonSlideQuadin:addComponent(DUIL.components.Hovered.new(function(object, enter)
	buttonColorQuadinAnim:setDirection(object, enter)
end))

---@type DUIL_PanelObject
local slideQuadinScale = DUIL.objects.Panel:new("slideQuadinScale")
mainPanel:addContent(slideQuadinScale)
slideQuadinScale:setConstraints(Constraints.UiConstraints.new(
	Constraints.TargetMod.new(buttonSlideQuadin, Constraints.ObjectRawX),
	Constraints.TargetMod.new(buttonSlideQuadin, Constraints.ObjectRawY) + Constraints.TargetMod.new(buttonSlideQuadin, Constraints.ObjectHeight) + Constraints.Pixel.new(20),
	Constraints.Pixel.new(200),
	Constraints.Aspect.new(0.25)
))
local slideQuadinScaleAnim = DUIL.components.TransformAnimation.new(
	Constraints.UiConstraints.new(
		Constraints.Zero,
		Constraints.Zero,
		Constraints.Zero,
		Constraints.Zero
	),
	Constraints.UiConstraints.new(
		Constraints.Pixel.new(30/2),
		Constraints.Pixel.new(10/2),
		Constraints.Pixel.new(-30),
		Constraints.Pixel.new(-10)
	),
	1, DUIL.components.TransformAnimation.modes.quadin
)
slideQuadinScale:addComponent(slideQuadinScaleAnim)
slideQuadinScale:addComponent(DUIL.components.Clicked.new(function(object, x, y, button)
	slideQuadinScaleAnim:trigger(object)
end))
local buttonColorQuadinScaleAnim = DUIL.components.ColorAnimation.new(
	nil,
	DUIL.Color.fromRGBA(0, 0, 0, 0),
	DUIL.Color.fromRGBA(-0.1, -0.1, 0.1, 0),
	0.1, DUIL.components.TransformAnimation.modes.linear
)
slideQuadinScale:addComponent(buttonColorQuadinScaleAnim)
slideQuadinScale:addComponent(DUIL.components.Hovered.new(function(object, enter)
	buttonColorQuadinScaleAnim:setDirection(object, enter)
end))


return mainPanel
