local DUIL = require "DUIL"


---@class DUIL_ImageObject
local Image = setmetatable({
	type="Image"
}, DUIL.Object)
Image.__index = Image
Image.__tostring = DUIL.Object.__tostring

function Image:draw(depth)
	if self.image ~= nil then
		local tint = self:getColor("imageTint")
		if tint ~= nil then
			tint:applyColor()
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.draw(self.image, 0, 0, 0, self:getWidth() / self.image:getWidth(), self:getHeight() / self.image:getHeight())
	else
		love.graphics.setColor(1, 0, 1, 1)
		love.graphics.rectangle("fill", 0, 0, self:getWidth(), self:getHeight())
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.printf("<NO IMAGE>", 0, 0, self:getWidth(), "center")
	end

	DUIL.Object.draw(self, depth)
end

---@param drawable Drawable
function Image:setImage(drawable)
	self.image = drawable
end


DUIL.objects.Image = Image -- Typing
DUIL.register(Image)
