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

local text = DUIL.objects.Text:new("text")
mainPanel:addContent(text)
text:setConstraints(Constraints.UiConstraints.new(
	Constraints.Zero,
	Constraints.Zero,
	Constraints.TargetMod.new("parent", Constraints.Percent.new(1))
	-- We dont care for a miniumum height of the text, so this was omitted
))
text:setAlignment("center")
text:setText("Some text\nAnother line\nThis line should be too long and split across multiple lines, look at it working as intended...\nPATATA!\nYouSeeThisLineItsTooLongWithoutSpacesSoItWorksYes?\nthenthesamethingasbeforebutnocapitalsandasyouseeitworking!")
text:addComponent(DUIL.components.Clicked.new(function(...)
	if text:getAlignment() == "left" then
		text:setAlignment("center")
	elseif text:getAlignment() == "center" then
		text:setAlignment("right")
	elseif text:getAlignment() == "right" then
		text:setAlignment("left")
	end
end))

local noText = DUIL.objects.Text:new("text")
mainPanel:addContent(noText)
noText:setConstraints(Constraints.UiConstraints.new(
	Constraints.Zero,
	Constraints.TargetMod.new("parent", Constraints.Percent.new(1)) - Constraints.Pixel.new(24),
	Constraints.TargetMod.new("parent", Constraints.Percent.new(1))
))
noText:setText("")

return mainPanel
