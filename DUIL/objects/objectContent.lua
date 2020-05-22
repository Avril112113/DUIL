local DUIL = require "DUIL"


---@class DUIL_ObjectContentObject
local ObjectContent = setmetatable({
	type="ObjectContent"
}, DUIL.Object)
ObjectContent.__index = ObjectContent
ObjectContent.__tostring = DUIL.Object.__tostring

-- function ObjectContent.new(objectClass, parent)
-- 	local self = DUIL.Object.new(objectClass)
-- 	self:setParent(parent)
-- 	return self
-- end

function ObjectContent:__index(index)
	if index == "name" then
		local name = self.parent.name
		if name ~= nil then
			return name .. "_content"
		else
			return nil
		end
	end
	return rawget(self, index) or (getmetatable(self) and getmetatable(self)[index] or nil)
end

DUIL.objects.ObjectContent = ObjectContent -- Typing
DUIL.register(ObjectContent)
