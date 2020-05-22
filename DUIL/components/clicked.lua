local DUIL = require "DUIL"


---@class DUIL_ClickedComponent : DUIL_Component
local Clicked = setmetatable({
	type="Clicked"
}, DUIL.Component)
Clicked.__index = Clicked
Clicked.__tostring = DUIL.Component.__tostring

function Clicked.new(callback)
	assert(type(callback) == "function")
	return setmetatable({
		callback=callback
	}, Clicked)
end

function Clicked:mousepressed(object, x, y, button)
	self.callback(object, x, y, button)
end

DUIL.components.Clicked = Clicked -- Typing
DUIL.register(Clicked)
