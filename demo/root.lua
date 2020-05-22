local DUIL = require "DUIL"
local Constraints = DUIL.Constraints


local UiRoot = DUIL.Object:new("UiRoot")
local UiRootConstraints = Constraints.UiConstraints.new(
	Constraints.Zero,
	Constraints.Zero,
	Constraints.Screen,
	Constraints.Screen
)
UiRoot:setConstraints(UiRootConstraints)

return UiRoot
