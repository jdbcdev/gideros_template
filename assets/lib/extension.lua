--[[
	TEXTFIELD EXTENSIONS
]]--

--[[ Completely overriding TextField ]]--

_TextField = TextField

TextField = Core.class(Sprite)

--[[ shadow implementation ]]--

function TextField:setShadow(offX, offY, color, alpha)
	if not self._shadow then
		self._shadow = _TextField.new(self._font, self._text:getText())
		self._shadow:setTextColor(self._text:getTextColor())
		self._shadow:setLetterSpacing(self._text:getLetterSpacing())
		self:addChildAtBack(self._shadow)
	end
	
	self._shadow:setPosition(offX + self._text:getX(), offY + self._text:getY())
	
	if color then
		self._shadow:setTextColor(color)
		if alpha then
			self._shadow:setAlpha(alpha)
		end
	end
	return self
end