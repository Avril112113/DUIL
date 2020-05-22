local DUIL = {
	---@type table<string, DUIL_Object>
	objects={},
	---@type table<string, DUIL_Skin>
	skins={},
	---@type table<string, DUIL_Component>
	components={},
	Constraints=require "DUIL.constraints",
	useStencilTest=false
}

local Constraints = DUIL.Constraints
local Utils = {}
DUIL.Utils = Utils

function Utils.IsInside(x1, y1, x2, y2, ix, iy)
	return ix > x1 and iy > y1 and ix < x2 and iy < y2
end
function Utils.Lerp(a, b, t)
	return a * (1-t) + b * t
end
function Utils.Quadin(a, b, t)
	return Utils.Lerp(a, b, t * t)
end
function Utils.Clamp(n, a, b)
	if n < a then return a
	elseif n > b then return b
	end
	return n
end
function Utils.GetMetatableMtRecursive(tbl, metatables)
	local mt = getmetatable(tbl)
	if mt == nil then return nil end
	local fmt = metatables[mt]
	if fmt ~= nil then return mt end
	return Utils.GetMetatableMtRecursive(mt, metatables)
end
function Utils.DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Utils.DeepCopy(orig_key)] = Utils.DeepCopy(orig_value)
        end
        setmetatable(copy, getmetatable(orig))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local DefaultConstraints = Constraints.UiConstraints.new()
DefaultConstraints:setX(Constraints.Zero)
DefaultConstraints:setY(Constraints.Zero)
DefaultConstraints:setWidth(Constraints.Zero)
DefaultConstraints:setHeight(Constraints.Zero)
DUIL.DefaultConstraints = DefaultConstraints

local DefaultContentBounds = Constraints.UiConstraints.new()
DefaultContentBounds:setX(Constraints.Zero)
DefaultContentBounds:setY(Constraints.Zero)
DefaultContentBounds:setWidth(Constraints.Percent.new(1))
DefaultContentBounds:setHeight(Constraints.Percent.new(1))
DUIL.DefaultContentBounds = DefaultContentBounds


---@class DUIL_Object
local Object = {
	type="object",
	---@type DUIL_UiConstraints
	contentBounds=DefaultContentBounds,
	---@type DUIL_Object
	parent=nil,
	---@type DUIL_UiConstraints
	constraints=DefaultConstraints,
	---@type table<DUIL_Object, DUIL_Object>
	children=nil,
	---@type table<DUIL_Component, DUIL_Component>
	components=nil,
	---@type table<string, DUIL_Color>
	colors=nil,
	---@type table<DUIL_UiConstraints, DUIL_UiConstraints>
	drivers=nil
}
Object.__index = Object
DUIL.Object = Object

--- NOTE: you can call this eg; `DUIL.objects.Panel:new()`
function Object.new(objectClass, name)
	assert(type(objectClass) == "table", "Invalid object class, are you using `.` instead of `:`?")
	return setmetatable({
		children={},
		components={},
		colors={},
		drivers={},
		name=name,
		previousBounds=nil,
		hidden=false
	}, objectClass)
end

function Object:__tostring()
	local namestr = ""
	if self.name ~= nil then
		namestr = " " .. self.name
	end
	return "<" .. self.type .. namestr .. " " .. tostring(self.constraints) .. ">"
end
function Object:shortString()
	local namestr = ""
	if self.name ~= nil then
		namestr = " " .. self.name
	end
	return "<" .. self.type .. namestr .. ">"
end

function Object:setName(name)
	self.name = name
end

---@return DUIL_Skin
function Object:getSkin()
	return self.skin or DUIL.activeSkin
end
---@return DUIL_Color
function Object:getColor(id)
	local color = self.colors[id] or self:getSkin():getColor(id)
	local createdColor = false
	for _, driver in pairs(self.drivers) do
		if driver.type == DUIL.ColorDriver.type or driver.type == DUIL.Color.type and (driver.id == nil or driver.id == id) then
			if not createdColor then
				color = DUIL.Color.fromRGBA(color.r, color.g, color.b, color.a)
			end
			color.r = color.r + driver.r
			color.g = color.g + driver.g
			color.b = color.b + driver.b
			color.a = color.a + driver.a
		end
	end
	if createdColor then
		print(color.r, color.g, color.b, color.a)
	end
	return color
end
function Object:applyColor(id)
	self:getColor(id):applyColor()
end
---@param color DUIL_Color
function Object:setColor(id, color)
	self.colors[id] = color
end

---@param parentObject DUIL_Object
function Object:setParent(parentObject)
	if self.parent ~= nil then
		self.parent:removeChild(self)
	end
	self.parent = parentObject
	parentObject:addChild(self)
end
---@param child DUIL_Object
function Object:addChild(child)
	self.children[child] = child
end
---@param child DUIL_Object
function Object:removeChild(child)
	self.children[child] = nil
end
function Object:getChildCount()
	local n = 0
	if self.children ~= nil then
		for _, _ in pairs(self.children) do
			n = n + 1
		end
	end
	return n
end

---@param component DUIL_Component
function Object:addComponent(component)
	self.components[component] = component
	component:added(self)
end
---@param component DUIL_Component
function Object:removeComponent(component)
	self.components[component] = nil
	component:removed(self)
end

function Object:show()
	self.hidden = false
end

function Object:hide()
	self.hidden = true
end

---@param driver any
function Object:addDriver(driver)
	assert(driver.type ~= nil, "Drivers must have a type field")
	self.drivers[driver] = driver
end
---@param driver any
function Object:removeDriver(driver)
	self.drivers[driver] = nil
end

---@param uiConstraints DUIL_UiConstraints
function Object:setConstraints(uiConstraints)
	self.constraints = uiConstraints
end
---@return DUIL_UiConstraints
function Object:getConstraints()
	return self.constraints
end
function Object:getX()
	local n = self.constraints:getX(self)
	for _, driver in pairs(self.drivers) do
		if driver.type == Constraints.UiConstraints.type then
			n = n + (driver:getX(self) or 0)
		end
	end
	return n
end
function Object:getXFromRoot()
	local n = self:getX()
	if self.parent ~= nil then
		n = n + self.parent:getXFromRoot()
	end
	return n
end
function Object:getY()
	local n = self.constraints:getY(self)
	for _, driver in pairs(self.drivers) do
		if driver.type == Constraints.UiConstraints.type then
			n = n + (driver:getY(self) or 0)
		end
	end
	return n
end
function Object:getYFromRoot()
	local n = self:getY()
	if self.parent ~= nil then
		n = n + self.parent:getYFromRoot()
	end
	return n
end
function Object:getWidth()
	local n = self.constraints:getWidth(self)
	for _, driver in pairs(self.drivers) do
		if driver.type == Constraints.UiConstraints.type then
			n = n + (driver:getWidth(self) or 0)
		end
	end
	return n
end
function Object:getHeight()
	local n = self.constraints:getHeight(self)
	for _, driver in pairs(self.drivers) do
		if driver.type == Constraints.UiConstraints.type then
			n = n + (driver:getHeight(self) or 0)
		end
	end
	return n
end

function Object:draw(depth)
	depth = depth or 1
	-- cb = Content Bounds
	for _, child in pairs(self.children) do
		if child.hidden ~= true then
			local objx, objy = child:getX(), child:getY()
			if DUIL.useStencilTest then
				love.graphics.stencil(function()
					love.graphics.rectangle("fill", 0, 0, self:getWidth(), self.getHeight())
				end, "replace", depth, true)
				love.graphics.setStencilTest("gequal", depth)
			end
			love.graphics.translate(objx, objy)
			child:draw(depth+1)
			love.graphics.translate(-objx, -objy)
		end
	end
	if depth == 1 and DUIL.useStencilTest then
		love.graphics.setStencilTest()
	end
end
function Object:update(dt)
	local x, y, w, h = self:getX(), self:getY(), self:getWidth(), self:getHeight()
	local posChanged = self.previousBounds == nil or self.previousBounds.x ~= x or self.previousBounds.y ~= y
	local sizeChanged = self.previousBounds == nil or self.previousBounds.w ~= w or self.previousBounds.h ~= h
	if posChanged or sizeChanged then
		self.previousBounds = {x=x, y=y, w=w, h=h}
		self:boundsChanged(posChanged, sizeChanged)
	end
	for _, component in pairs(self.components) do
		component:update(self, dt)
	end
	for _, child in pairs(self.children) do
		child:update(dt)
	end
end
function Object:mousemoved(x, y, dx, dy, istouch)
	for _, component in pairs(self.components) do
		component:mousemoved(self, x, y, dx, dy, istouch)
	end
	for _, child in pairs(self.children) do
		if child.hidden ~= true then
			local objx, objy, objw, objh = child:getX(), child:getY(), child:getWidth(), child:getHeight()
			if Utils.IsInside(objx - dx, objy - dy, objx + objw + dx, objy + objh + dy, x, y) then
				-- TODO: additional arguemnt to spesify if the mouse was moved outside and is no longer within the child
				child:mousemoved(x-objx, y-objy, dx, dy, istouch)
			end
		end
	end
end
function Object:mousepressed(x, y, button)
	for _, component in pairs(self.components) do
		component:mousepressed(self, x, y, button)
	end
	for _, child in pairs(self.children) do
		if child.hidden ~= true then
			local objx, objy, objw, objh = child:getX(), child:getY(), child:getWidth(), child:getHeight()
			if Utils.IsInside(objx, objy, objx + objw, objy + objh, x, y) then
				child:mousepressed(x-objx, y-objy, button)
			end
		end
	end
end
function Object:mousereleased(x, y, button)
	for _, component in pairs(self.components) do
		component:mousereleased(self, x, y, button)
	end
	for _, child in pairs(self.children) do
		if child.hidden ~= true then
			local objx, objy, objw, objh = child:getX(), child:getY(), child:getWidth(), child:getHeight()
			if Utils.IsInside(objx, objy, objx + objw, objy + objh, x, y) then
				child:mousereleased(x-objx, y-objy, button)
			end
		end
	end
end
function Object:keypressed(key, isrepeat)
	for _, component in pairs(self.components) do
		component:keypressed(self, key, isrepeat)
	end
	-- TODO: check if child has focus
	for _, child in pairs(self.children) do
		if child.hidden ~= true then
			child:keypressed(key, isrepeat)
		end
	end
end
function Object:keyreleased(key)
	for _, component in pairs(self.components) do
		component:keyreleased(self, key)
	end
	-- TODO: check if child has focus
	for _, child in pairs(self.children) do
		if child.hidden ~= true then
			child:keyreleased(key)
		end
	end
end
function Object:boundsChanged(posChanged, sizeChanged)
	for _, component in pairs(self.components) do
		component:boundsChanged(self, posChanged, sizeChanged)
	end
end

---@class DUIL_Component
--- Functional component that can be added to any object
--- A component does not draw anything, but can call callbacks or change the object it's self though note; the object could be anything
local Component = {
	type="component"
}
Component.__index = Component
DUIL.Component = Component

function Component:__tostring()
	return "<Compnent " .. self.type .. ">"
end

---@param object DUIL_Object
function Component:update(object, dt)
end
---@param object DUIL_Object
function Component:mousemoved(object, x, y, dx, dy, istouch)
end
---@param object DUIL_Object
function Component:mousepressed(object, x, y, button)
end
---@param object DUIL_Object
function Component:mousereleased(object, x, y, button)
end
---@param object DUIL_Object
function Component:keypressed(object, key, isrepeat)
end
---@param object DUIL_Object
function Component:keyreleased(object, key)
end
---@param object DUIL_Object
function Component:boundsChanged(object, posChanged, sizeChanged)
end
---@param object DUIL_Object
function Component:added(object)
end
---@param object DUIL_Object
function Component:removed(object)
end


---@class DUIL_Color
local Color = {
	type="color",
	---@type number
	r=nil,
	---@type number
	g=nil,
	---@type number
	b=nil,
	---@type number
	a=nil,
}
Color.__index = Color
DUIL.Color = Color

function Color.fromRGBA(r, g, b, a)
	return setmetatable({
		r=r or 1,
		g=g or 1,
		b=b or 1,
		a=a or 1
	}, Color)
end
function Color.fromHexStr(s)
	local r, g, b, a
	local colorSize = math.ceil(#s / 4)
	local divisor = 16 ^ colorSize - 1
	local rc, gc, bc, ac = s:sub(1, 1*colorSize), s:sub(1*colorSize+1, 2*colorSize), s:sub(2*colorSize+1, 3*colorSize), s:sub(3*colorSize+1, 4*colorSize)
	r = tonumber("0x" .. rc); r = r and r / divisor or 1
	g = tonumber("0x" .. gc); g = g and g / divisor or 1
	b = tonumber("0x" .. bc); b = b and b / divisor or 1
	a = tonumber("0x" .. ac); a = a and a / divisor or 1
	return setmetatable({
		r=r,
		g=g,
		b=b,
		a=a
	}, Color)
end

function Color:getRGBA()
	return self.r, self.g, self.b, self.a
end
function Color:getHexStr()
	return string.format("%x", math.floor(self.r * 255)) .. string.format("%x", math.floor(self.g * 255)) .. string.format("%x", math.floor(self.b * 255)) .. string.format("%x", math.floor(self.a * 255))
end
function Color:applyColor()
	love.graphics.setColor(self.r, self.g, self.b, self.a)
end

local ColorDriver = {
	type="colorDriver",
	---@type DUIL_Color
	color=nil
}
DUIL.ColorDriver = ColorDriver
function ColorDriver:__index(index)
	if index == "r" then return rawget(self, "color").r end
	if index == "g" then return rawget(self, "color").g end
	if index == "b" then return rawget(self, "color").b end
	if index == "a" then return rawget(self, "color").a end
	return rawget(self, index) or ColorDriver[index]
end
function ColorDriver.new(id, color)
	return setmetatable({
		id=id,
		color=color
	}, ColorDriver)
end


---@class DUIL_Skin
local Skin = {
	---@type table<string, DUIL_Color>
	colors={}
}
DUIL.Skin = Skin
function Skin:__index(index)
	return rawget(self, index) or rawget(Skin, index) or Skin.getColor(self, index)
end
---@return DUIL_Color
function Skin:getColor(id)
	return rawget(self, "colors")[id] or (rawget(self, "fallback") and rawget(self, "fallback"):getColor(id))
end
---@param object DUIL_Object
---@return DUIL_Color
function Skin:draw(id, object, ...)
	local f = rawget(self, "drawFuncs")[id] or (rawget(self, "fallback") and rawget(self, "fallback"):draw(id))
	if f ~= nil then
		f(object, ...)
	end
end


local registerableMts = {[Object]=Object, [Component]=Component, [Skin]=Skin}
function DUIL.register(object)
	local mt = Utils.GetMetatableMtRecursive(object, registerableMts)
	if mt == Object then
		assert(type(object.type) == "string")
		DUIL.objects[object.type] = object
	elseif mt == Component then
		assert(type(object.type) == "string")
		DUIL.components[object.type] = object
	elseif mt == Skin then
		assert(type(object.type) == "string")
		DUIL.skins[object.type] = object
	else
		error("Attempt to register an unknown feature. (Invalid metatable)")
	end
end

---@type DUIL_Object
function DUIL.getObjectAt(root, x, y)
	local prevObject
	local currentObject = root
	while currentObject ~= prevObject and currentObject.children ~= nil and currentObject:getChildCount() > 0 do
		prevObject = currentObject
		for _, child in pairs(currentObject.children) do
			local objx, objy, objw, objh = child:getX(), child:getY(), child:getWidth(), child:getHeight()
			if Utils.IsInside(objx, objy, objx + objw, objy + objh, x, y) then
				x, y = x - objx, y - objy
				currentObject = child
				break
			end
		end
	end
	return currentObject
end

function DUIL.drawDebug(root, px, py)
	local obj = DUIL.getObjectAt(root, px, py)

	if obj ~= nil then
		local headStr = "Object: "
		if obj.name ~= nil then headStr = headStr .. obj.name else headStr = headStr .. obj.type end
		if obj.parent ~= nil then
			headStr = headStr .. " with parent: "
			if obj.parent.name ~= nil then headStr = headStr .. obj.parent.name else headStr = headStr .. obj.parent.type end
		end
		local relitivePosStr = "From Parent X: " .. tostring(obj:getX()) .. " Y: " .. tostring(obj:getY())
		local rootPosStr = "From Root X: " .. tostring(obj:getXFromRoot()) .. " Y: " .. tostring(obj:getYFromRoot())
		local sizeStr = "Width: " .. tostring(obj:getWidth()) .. " Height: " .. tostring(obj:getHeight())

		local font = love.graphics.getFont()
		local width, height = font:getWidth(relitivePosStr), font:getHeight() * 4
		if font:getWidth(headStr) > width then width = font:getWidth(headStr) end
		if font:getWidth(rootPosStr) > width then width = font:getWidth(rootPosStr) end
		if font:getWidth(sizeStr) > width then width = font:getWidth(sizeStr) end

		love.graphics.setColor(0.65, 0.65, 0.65, 0.95)
		love.graphics.rectangle("fill", 0, 0, width, height)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(headStr, 0, font:getHeight() * 0)
		love.graphics.print(relitivePosStr, 0, font:getHeight() * 1)
		love.graphics.print(rootPosStr, 0, font:getHeight() * 2)
		love.graphics.print(sizeStr, 0, font:getHeight() * 3)
		love.graphics.setColor(1, 1, 0, 0.65)
		love.graphics.setLineWidth(3)
		love.graphics.rectangle("line", obj:getXFromRoot(), obj:getYFromRoot(), obj:getWidth(), obj:getHeight())
	end
end

---@param object DUIL_Object
function DUIL.draw(object)
	local objx, objy = object:getX(), object:getY()
	love.graphics.translate(objx, objy)
	object:draw()
	love.graphics.translate(-objx, -objy)
end
---@param object DUIL_Object
function DUIL.update(object, dt)
	object:update(dt)
end
---@param object DUIL_Object
function DUIL.mousemoved(object, x, y, dx, dy, istouch)
	object:mousemoved(x, y, dx, dy, istouch)
end
---@param object DUIL_Object
function DUIL.mousepressed(object, x, y, button)
	object:mousepressed(x, y, button)
end
---@param object DUIL_Object
function DUIL.mousereleased(object, x, y, button)
	object:mousereleased(x, y, button)
end
---@param object DUIL_Object
function DUIL.keypressed(object, key, isrepeat)
	object:keypressed(key, isrepeat)
end
---@param object DUIL_Object
function DUIL.keyreleased(object, key)
	object:keyreleased(key)
end


-- Required for loading objects and skins
package.loaded["DUIL"] = DUIL

for _, fileName in pairs(love.filesystem.getDirectoryItems("DUIL/objects")) do
	local fileNameExcExt = fileName:sub(0, -5)
	if fileName:sub(-4, -1) == ".lua" and fileNameExcExt ~= "init" then
		require("DUIL.objects." .. fileNameExcExt)
	end
end

for _, fileName in pairs(love.filesystem.getDirectoryItems("DUIL/components")) do
	local fileNameExcExt = fileName:sub(0, -5)
	if fileName:sub(-4, -1) == ".lua" and fileNameExcExt ~= "init" then
		require("DUIL.components." .. fileNameExcExt)
	end
end

for _, fileName in pairs(love.filesystem.getDirectoryItems("DUIL/skins")) do
	local fileNameExcExt = fileName:sub(0, -5)
	if fileName:sub(-4, -1) == ".lua" and fileNameExcExt ~= "init" then
		require("DUIL.skins." .. fileNameExcExt)
	end
end

---@type DUIL_Skin
DUIL.activeSkin = DUIL.skins.light

return DUIL