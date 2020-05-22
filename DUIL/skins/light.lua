local DUIL = require "DUIL"

local light = setmetatable({
	type="light",
	colors={
		background=DUIL.Color.fromRGBA(1, 1, 1, 1),
		border=DUIL.Color.fromRGBA(0.75, 0.75, 0.75, 1),
		primary=DUIL.Color.fromRGBA(0.85, 0.85, 0.85, 1),
		text=DUIL.Color.fromRGBA(0, 0, 0, 1),
		controlButtonColor=DUIL.Color.fromRGBA(0, 0, 0, 1),  -- Like `x` and `-` close, collapse or uncollapse button
	},
	drawFuncs={
		---@param object DUIL_Object
		cross=function(object, x, y, w, h)
			assert(type(x) == "number", "x is not a number")
			assert(type(y) == "number", "y is not a number")
			assert(type(w) == "number", "w is not a number")
			assert(type(h) == "number", "h is not a number")
			local lw = love.graphics.getLineWidth()
			local off = lw/2-1
			x, y = x - off, y - off
			w, h = w - off*2, h - off*2
			love.graphics.line(x, y, x+w, y+h)
			love.graphics.line(x+w, y, x, y+h)
		end
	}
}, DUIL.Skin)

DUIL.register(light)
