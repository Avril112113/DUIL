local Constraints = {}


---@class DUIL_UiConstraints
local UiConstraints = {
	type="ui_constraints",  -- as this can be a driver, it needs a type
	---@type DUIL_Constraint
	x=nil,
	---@type DUIL_Constraint
	y=nil,
	---@type DUIL_Constraint
	width=nil,
	---@type DUIL_Constraint
	height=nil,
}
UiConstraints.__index = UiConstraints
Constraints.UiConstraints = UiConstraints
---@param xConstraint DUIL_Constraint
---@param yConstraint DUIL_Constraint
---@param widthConstraint DUIL_Constraint
---@param heightConstraint DUIL_Constraint
function UiConstraints.new(xConstraint, yConstraint, widthConstraint, heightConstraint)
	return setmetatable({
		x=xConstraint,
		y=yConstraint,
		width=widthConstraint,
		height=heightConstraint
	}, UiConstraints)
end
function UiConstraints:__tostring()
	return "<Ui x: " .. tostring(self.x) .. " y: " .. tostring(self.y) .. " w: " .. tostring(self.width) .. " h: " .. tostring(self.height) .. ">"
end
---@param constraint DUIL_Constraint
function UiConstraints:setX(constraint)
	self.x = constraint
end
---@param constraint DUIL_Constraint
function UiConstraints:setY(constraint)
	self.y = constraint
end
---@param constraint DUIL_Constraint
function UiConstraints:setWidth(constraint)
	self.width = constraint
end
---@param constraint DUIL_Constraint
function UiConstraints:setHeight(constraint)
	self.height = constraint
end

---@param object DUIL_Object
function UiConstraints:getX(object)
	assert(type(object) == "table", "Invalid object")
	return self.x and self.x:get(1, object) or nil
end
---@param object DUIL_Object
function UiConstraints:getY(object)
	assert(type(object) == "table", "Invalid object")
	return self.y and self.y:get(2, object) or nil
end
---@param object DUIL_Object
function UiConstraints:getWidth(object)
	assert(type(object) == "table", "Invalid object")
	return self.width and self.width:get(3, object) or nil
end
---@param object DUIL_Object
function UiConstraints:getHeight(object)
	assert(type(object) == "table", "Invalid object")
	return self.height and self.height:get(4, object) or nil
end


---@param constraint DUIL_Constraint
local function setupNewConstraintType(constraint)
	constraint.__add = constraint.__add or Constraints.Constraint.__add
	constraint.__sub = constraint.__sub or Constraints.Constraint.__sub
	constraint.__mul = constraint.__mul or Constraints.Constraint.__mul
	constraint.__div = constraint.__div or Constraints.Constraint.__div
	constraint.__index = constraint

	setmetatable(constraint, Constraints.Constraint)
end
Constraints.setupNewConstraintType = setupNewConstraintType


---@class DUIL_Constraint
local Constraint = {}
Constraint.__index = Constraint
Constraints.Constraint = Constraint
Constraint.__tostring = function(self) return self:__tostring() end
function Constraint:__add(other)
	return Constraints.Concat.new(self, "+", other)
end
function Constraint:__sub(other)
	return Constraints.Concat.new(self, "-", other)
end
function Constraint:__mul(other)
	return Constraints.Concat.new(self, "*", other)
end
function Constraint:__div(other)
	return Constraints.Concat.new(self, "/", other)
end
---@param pos number
---@param object DUIL_Object
function Constraint:get(pos, object) error() end


---@class DUIL_ConcatConstraint : DUIL_Constraint
local ConcatConstraint = {}
Constraints.setupNewConstraintType(ConcatConstraint)
Constraints.Concat = ConcatConstraint
---@param a DUIL_Object
---@param b DUIL_Object
function ConcatConstraint.new(a, op, b)
	assert(type(a) == "table" or type(a) == "number")
	assert(type(b) == "table" or type(b) == "number")
	return setmetatable({
		a=a, op=op, b=b
	}, ConcatConstraint)
end
function ConcatConstraint:__tostring()
	return "<" .. tostring(self.a) .. " " .. self.op .. " " .. tostring(self.b) .. ">"
end
function ConcatConstraint:get(pos, object)
	local a = type(self.a) == "number" and self.a or self.a:get(pos, object)
	local b = type(self.b) == "number" and self.b or self.b:get(pos, object)
	if self.op == "+" then
		return a + b
	elseif self.op == "-" then
		return a - b
	elseif self.op == "*" then
		return a * b
	elseif self.op == "/" then
		return a / b
	end
	error("Unknown op '" .. self.op .. "'")
end


---@class DUIL_ZeroConstraint : DUIL_Constraint
local ZeroConstraint = {}
Constraints.setupNewConstraintType(ZeroConstraint)
Constraints.Zero = ZeroConstraint
function ZeroConstraint:__tostring()
	return "<Zero>"
end
function ZeroConstraint:get(pos, object)
	return 0
end

---@class DUIL_ScreenConstraint : DUIL_Constraint
local ScreenConstraint = {}
Constraints.setupNewConstraintType(ScreenConstraint)
Constraints.Screen = ScreenConstraint
function ScreenConstraint:__tostring()
	return "<Screen>"
end
function ScreenConstraint:get(pos, object)
	if pos == 1 or pos == 3 then
		return love.graphics.getWidth()
	else
		return love.graphics.getHeight()
	end
end

---@class DUIL_PixelConstraint : DUIL_Constraint
local PixelConstraint = {}
Constraints.setupNewConstraintType(PixelConstraint)
Constraints.Pixel = PixelConstraint
---@param n number
function PixelConstraint.new(n)
	assert(type(n) == "number")
	return setmetatable({
		n=n
	}, PixelConstraint)
end
function PixelConstraint:__tostring()
	return "<Pixel: " .. self.n .. ">"
end
function PixelConstraint:get(pos, object)
	return self.n
end

---@class DUIL_PercentConstraint : DUIL_Constraint
local PercentConstraint = {}
Constraints.setupNewConstraintType(PercentConstraint)
Constraints.Percent = PercentConstraint
---@param percent number
function PercentConstraint.new(percent)
	assert(type(percent) == "number")
	return setmetatable({
		percent=percent
	}, PercentConstraint)
end
function PercentConstraint:__tostring()
	return "<Relative: " .. self.percent .. ">"
end
function PercentConstraint:get(pos, object)
	if pos == 1 or pos == 3 then
		return object:getWidth() * self.percent
	else
		return object:getHeight() * self.percent
	end
end

---@class DUIL_AspectConstraint : DUIL_Constraint
local AspectConstraint = {}
Constraints.setupNewConstraintType(AspectConstraint)
Constraints.Aspect = AspectConstraint
---@param aspect number|nil
function AspectConstraint.new(aspect)
	return setmetatable({
		aspect=aspect or 1
	}, AspectConstraint)
end
function AspectConstraint:__tostring()
	return "<Aspect: " .. self.aspect .. ">"
end
function AspectConstraint:get(pos, object)
	if pos == 1 or pos == 3 then
		return object:getHeight() * self.aspect
	else
		return object:getWidth() * self.aspect
	end
end

---@class DUIL_ObjectXConstraint : DUIL_Constraint
local ObjectXConstraint = {}
Constraints.setupNewConstraintType(ObjectXConstraint)
Constraints.ObjectX = ObjectXConstraint
function ObjectXConstraint:__tostring()
	return "<ObjectX>"
end
function ObjectXConstraint:get(pos, object)
	return object:getX()
end

---@class DUIL_ObjectYConstraint : DUIL_Constraint
local ObjectYConstraint = {}
Constraints.setupNewConstraintType(ObjectYConstraint)
Constraints.ObjectY = ObjectYConstraint
function ObjectYConstraint:__tostring()
	return "<ObjectY>"
end
function ObjectYConstraint:get(pos, object)
	return object:getY()
end

---@class DUIL_ObjectWidthConstraint : DUIL_Constraint
local ObjectWidthConstraint = {}
Constraints.setupNewConstraintType(ObjectWidthConstraint)
Constraints.ObjectWidth = ObjectWidthConstraint
function ObjectWidthConstraint:__tostring()
	return "<ObjectWidth>"
end
function ObjectWidthConstraint:get(pos, object)
	return object:getWidth()
end

---@class DUIL_ObjectHeightConstraint : DUIL_Constraint
local ObjectHeightConstraint = {}
Constraints.setupNewConstraintType(ObjectHeightConstraint)
Constraints.ObjectHeight = ObjectHeightConstraint
function ObjectHeightConstraint:__tostring()
	return "<ObjectHeight>"
end
function ObjectHeightConstraint:get(pos, object)
	return object:getHeight()
end

---@class DUIL_ObjectRawXConstraint : DUIL_Constraint
local ObjectRawXConstraint = {}
Constraints.setupNewConstraintType(ObjectRawXConstraint)
Constraints.ObjectRawX = ObjectRawXConstraint
function ObjectRawXConstraint:__tostring()
	return "<ObjectRawX>"
end
function ObjectRawXConstraint:get(pos, object)
	return object.constraints:getX(object)
end

---@class DUIL_ObjectRawYConstraint : DUIL_Constraint
local ObjectRawYConstraint = {}
Constraints.setupNewConstraintType(ObjectRawYConstraint)
Constraints.ObjectRawY = ObjectRawYConstraint
function ObjectRawYConstraint:__tostring()
	return "<ObjectRawY>"
end
function ObjectRawYConstraint:get(pos, object)
	return object.constraints:getY(object)
end

---@class DUIL_ObjectRawWidthConstraint : DUIL_Constraint
local ObjectRawWidthConstraint = {}
Constraints.setupNewConstraintType(ObjectRawWidthConstraint)
Constraints.ObjectRawWidth = ObjectRawWidthConstraint
function ObjectRawWidthConstraint:__tostring()
	return "<ObjectRawWidth>"
end
function ObjectRawWidthConstraint:get(pos, object)
	return object.constraints:getWidth(object)
end

---@class DUIL_ObjectRawHeightConstraint : DUIL_Constraint
local ObjectRawHeightConstraint = {}
Constraints.setupNewConstraintType(ObjectRawHeightConstraint)
Constraints.ObjectRawHeight = ObjectRawHeightConstraint
function ObjectRawHeightConstraint:__tostring()
	return "<ObjectRawHeight>"
end
function ObjectRawHeightConstraint:get(pos, object)
	return object.constraints:getHeight(object)
end

---@class DUIL_RelativeConstraint : DUIL_Constraint
local RelativeConstraint = {}
Constraints.setupNewConstraintType(RelativeConstraint)
Constraints.Relative = RelativeConstraint
---@param object DUIL_Object
function RelativeConstraint.new(object)
	return setmetatable({
		object=object
	}, RelativeConstraint)
end
function RelativeConstraint:__tostring()
	return "<RelativeConstraint: " .. tostring(self.object:shortString()) .. ">"
end
function RelativeConstraint:get(pos, object)
	local value
	if pos == 1 or pos == 3 then
		value = self.object:getX() + self.object:getWidth()
	else
		value = self.object:getY() + self.object:getHeight()
	end
	return value
end

---@class DUIL_TargetMod : DUIL_Constraint
local TargetMod = {}
Constraints.setupNewConstraintType(TargetMod)
Constraints.TargetMod = TargetMod
---@param object DUIL_Object|"parent"
---@param constraint DUIL_Constraint
function TargetMod.new(object, constraint)
	return setmetatable({
		object=object,
		constraint=constraint
	}, TargetMod)
end
function TargetMod:__tostring()
	local objStr
	if self.object == "parent" then
		objStr = "REL:PARENT"
	else
		objStr = self.object:shortString()
	end
	return "<TargetMod: " .. objStr .. ", " .. tostring(self.constraint) .. ">"
end
function TargetMod:get(pos, object)
	if self.object == "parent" then
		assert(type(object.parent) == "table", tostring(self) .. " got invalid parent object")
		return self.constraint:get(pos, object.parent)
	else
		return self.constraint:get(pos, self.object)
	end
end

---@class DUIL_Proxy : DUIL_Constraint
local Proxy = {}
Constraints.setupNewConstraintType(Proxy)
Constraints.Proxy = Proxy
---@param object DUIL_Object|"parent"
---@param constraint DUIL_Constraint
function Proxy.new(object, constraint)
	return setmetatable({
		object=object,
		constraint=constraint
	}, Proxy)
end
function Proxy:__tostring()
	return "<Proxy: " .. tostring(self.constraint) .. ">"
end
function Proxy:get(pos, object)
	if self.object == "parent" then
		assert(type(object.parent) == "table", tostring(self) .. " got invalid parent object")
		return self.constraint:get(pos, object.parent)
	else
		return self.constraint:get(pos, self.object)
	end
end
function Proxy:setConstraint(constraint)
	self.constraint = constraint
end

---@class DUIL_Get : DUIL_Constraint
local Get = {}
Constraints.setupNewConstraintType(Get)
Constraints.Get = Get
---@param func function
function Get.new(func)
	return setmetatable({
		func=func
	}, Get)
end
function Get:__tostring()
	return "<Get: " .. tostring(self.func) .. ">"
end
function Get:get(pos, object)
	return self:func()
end


return Constraints
