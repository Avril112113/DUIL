local DUIL = require "DUIL"


---@class DUIL_TextObject
local Text = setmetatable({
	type="Text",
	defaultTextFont=love.graphics.setNewFont(18),
	align="left",
	text={},
	---@type number
	height=nil
}, DUIL.Object)
Text.__index = Text
Text.__tostring = DUIL.Object.__tostring

function Text:draw(depth)
	for _, data in pairs(self.textdata) do
		if data.font ~= nil then
			love.graphics.setFont(data.font)
		end
		if data.color ~= nil then
			data.color:applyColor()
		end
		love.graphics.print(data.text, data.x, data.y)
	end

	DUIL.Object.draw(self, depth)
end

function Text:boundsChanged(posChanged, sizeChanged)
	if sizeChanged then
		self:calcuateTextData()
	end

	DUIL.Object.boundsChanged(self, posChanged, sizeChanged)
end

function Text:calcuateTextData()
	local maxWidth = self:getWidth()

	self.textdata = {}
	local prevHighestText = 0
	local highestText = 0
	local x, y = 0, 0
	local lastLineStartIndex = 1
	local function newLine()
		-- calcuate alignment
		if self.align ~= "left" then
			local lineWidth = 0
			for i=lastLineStartIndex, #self.textdata do
				local td = self.textdata[i]
				local xPlusWidth = td.x + td.staticFont:getWidth(td.text)
				if xPlusWidth > lineWidth then
					lineWidth = xPlusWidth
				end
			end
			local xOffset
			if self.align == "center" then
				xOffset = (maxWidth - lineWidth) / 2
			elseif self.align == "right" then
				xOffset = maxWidth - lineWidth
			end
			for i=lastLineStartIndex, #self.textdata do
				local td = self.textdata[i]
				td.x = td.x + xOffset
			end
		end
		lastLineStartIndex = #self.textdata+1
		-- set values for the new line
		x = 0
		y = y + highestText
		prevHighestText = highestText
		highestText = 0
	end

	local prevFont
	local prevColor
	for _, text in ipairs(self.text) do
		local str
		if type(text) == "string" then
			str = text
		else
			str = text.text
		end
		local font = (text and text.font) or prevFont or self.defaultTextFont
		local color = (text and text.color) or prevColor or self:getColor("text")
		for line in str:gmatch("[^\n]+") do
			local sections = {}
			-- There probably is a much better and efficent way of doing this
			for section in line:gmatch("[^ ]+ ?") do
				if font:getWidth(section) > maxWidth then
					for section in line:gmatch("[%u%p]?[^%u%p]*") do
						if font:getWidth(section) > maxWidth then
							local s = ""
							while #section > 0 do
								if font:getWidth(s .. section:sub(1, 1)) > maxWidth then
									table.insert(sections, s)
									s = ""
								end
								s = s .. section:sub(1, 1)
								section = section:sub(2, -1)
							end
							table.insert(sections, s)
						else
							table.insert(sections, section)
						end
					end
				else
					table.insert(sections, section)
				end
			end

			for _, section in ipairs(sections) do
				local sectionWidth = font:getWidth(section)
				if x + sectionWidth > maxWidth then
					if font:getHeight() > highestText then
						highestText = font:getHeight()
					end
					newLine()
					if section:sub(-1, -1) == " " then
						section = section:sub(1, -2)
					end
				end

				local strFont, strColor
				if prevFont ~= font then strFont = font; prevFont = font end
				if prevColor ~= color then strColor = color; prevColor = color end
				table.insert(self.textdata, {
					text=section,
					font=strFont,
					staticFont=font,  -- used for alignment calcuations
					color=strColor,
					x=x, y=y
				})
				x = x + sectionWidth
			end

			if font:getHeight() > highestText then
				highestText = font:getHeight()
			end
			newLine()
		end
	end

	if #self.textdata > 0 then
		self.height = self.textdata[#self.textdata].y + prevHighestText
	else
		self.height = 0
	end
end

function Text:setDefaultFont(font)
	self.defaultTextFont = font
	self:calcuateTextData()
end

function Text:setAlignment(align)
	assert(align == "left" or align == "center" or align == "right", "Invalid align mode '" .. tostring(align) .. "'")
	self.align = align
	self:calcuateTextData()
end
function Text:getAlignment()
	return self.align
end

function Text:setText(text)
	if type(text) == "string" then
		self.text = {text}
	else
		self.text = text
	end
	self:calcuateTextData()
end

function Text:getHeight()
	local height = self.height
	local fontHeight = self.defaultTextFont:getHeight()
	if height == nil or fontHeight > height then height = fontHeight end
	local constraintHeight = DUIL.Object.getHeight(self)
	if constraintHeight ~= nil and (height == nil or constraintHeight > height) then height = constraintHeight end
	return height
end

DUIL.objects.Text = Text -- Typing
DUIL.register(Text)
