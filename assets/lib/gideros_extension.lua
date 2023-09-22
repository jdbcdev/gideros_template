--[[
	TEXTFIELD EXTENSIONS
]]--

--[[ Completely overriding TextField ]]--

_TextField = TextField

TextField = Core.class(Sprite)

function TextField:init(...)
	local arg = {...}
	self._text = _TextField.new(...)
	self:addChild(self._text)
	self._font = arg[1]
	self._offsetX = 0
	self._offsetY = 0
	
	local baseX, baseY = self._text:getBounds(stage)
	self._text:setPosition(-baseX, -baseY)
end

function TextField:setText(...)
	self._text:setText(...)
	if self._shadow then
		self._shadow:setText(...)
	end
	return self
end

function TextField:getText()
	return self._text:getText()
end

function TextField:setTextColor(...)
	self._text:setTextColor(...)
	if self._shadow then
		self._shadow:setTextColor(...)
	end
	return self
end

function TextField:getTextColor()
	return self._text:getTextColor()
end

function TextField:setLetterSpacing(...)
	self._text:setLetterSpacing(...)
	if self._shadow then
		self._shadow:setLetterSpacing(...)
	end
	return self
end

function TextField:getLetterSpacing()
	return self._text:getLetterSpacing()
end

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
	
		--[[
	SHAPE EXTENSIONS
]]--

--[[ draw a polygon from a list of vertices ]]--

function Shape:drawPoly(points)
	local drawOp=self.moveTo
	self:beginPath()
	if type(points[1]) == "table" then
		for i,p in ipairs(points) do
			drawOp(self, p[1], p[2])
			drawOp=self.lineTo
		end
	else
		for i = 1, #points, 2 do
			drawOp(self, points[i], points[i+1])
			drawOp=self.lineTo
		end
	end
	self:closePath()
	self:endPath()
	return self
end

--[[ draw rectangle ]]--

function Shape:drawRectangle(width, height)
	return self:drawPoly({
		{0, 0},
		{width, 0},
		{width, height},
		{0, height}
	})
end

--[[ arcs and curves ]]--

local function bezier3(p1,p2,p3,mu)
   local mum1,mum12,mu2
   local p = {}
   mu2 = mu * mu
   mum1 = 1 - mu
   mum12 = mum1 * mum1
   p.x = p1.x * mum12 + 2 * p2.x * mum1 * mu + p3.x * mu2
   p.y = p1.y * mum12 + 2 * p2.y * mum1 * mu + p3.y * mu2
   return p
end

local function bezier4(p1,p2,p3,p4,mu)
   local mum1,mum13,mu3;
   local p = {}
   mum1 = 1 - mu
   mum13 = mum1 * mum1 * mum1
   mu3 = mu * mu * mu
   p.x = mum13*p1.x + 3*mu*mum1*mum1*p2.x + 3*mu*mu*mum1*p3.x + mu3*p4.x
   p.y = mum13*p1.y + 3*mu*mum1*mum1*p2.y + 3*mu*mu*mum1*p3.y + mu3*p4.y
   return p     
end

local function quadraticCurve(startx, starty, cpx, cpy, x, y, mu)
	local inc = mu or 0.1 -- need a better default
	local t = {}
	for i = 0,1,inc do
		local p = bezier3(
			{ x=startx, y=starty },
			{ x=cpx, y=cpy },
			{ x=x, y=y },
		i)
		t[#t+1] = p.x
		t[#t+1] = p.y
	end
	return t
end

Shape._new = Shape.new

function Shape.new()
	local shape = Shape._new()
	shape._lastPoint = nil
	shape._allPoints = {}
	return shape
end

Shape._moveTo = Shape.moveTo

function Shape:moveTo(x,y)
	self:_moveTo(x, y)
	self._lastPoint = { x, y }
	self._allPoints[#self._allPoints+1] = x
	self._allPoints[#self._allPoints+1] = y
	return self
end

Shape._lineTo = Shape.lineTo

function Shape:lineTo(x,y)
	self:_lineTo(x, y)
	self._lastPoint = { x, y }
	self._allPoints[#self._allPoints+1] = x
	self._allPoints[#self._allPoints+1] = y
	return self
end

Shape._clear = Shape.clear

function Shape:clear()
	self:_clear()
	self._allPoints = {}
	return self
end

function Shape:getPoints()
	return self._allPoints
end

function Shape:quadraticCurveTo(cpx, cpy, x, y, mu)
	if self._lastPoint then
		local points = quadraticCurve(self._lastPoint[1], self._lastPoint[2], cpx, cpy, x, y, mu)
		for i = 1, #points, 2 do
			self:lineTo(points[i],points[i+1])
		end
	end
	self._lastPoint = { x, y }
	return self
end

function Shape:bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y, mu)
	if self._lastPoint then
		local inc = mu or 0.1 -- need a better default
		for i = 0,1,inc do  
			local p = bezier4(
				{ x=self._lastPoint[1], y=self._lastPoint[2] },
				{ x=cp1x, y=cp1y },
				{ x=cp2x, y=cp2y },
				{ x=x, y=y },
			i)
			self:lineTo(p.x,p.y)
		end
	end
	self._lastPoint = { x, y }
	return self
end

function Shape:drawRoundRectangle(width, height, radius)
	self:beginPath()
	self:moveTo(0, radius)
		:lineTo(0, height - radius)
		:quadraticCurveTo(0, height, 
			radius, height)
		:lineTo(width - radius, height)
		:quadraticCurveTo(width, height, 
			width, height - radius)
		:lineTo(width, radius)
		:quadraticCurveTo(width, 0, 
			width - radius, 0)
		:lineTo(radius, 0)
		:quadraticCurveTo(0, 0, 
			0, radius)
	self:closePath()
	self:endPath()
	return self
end

--[[ draw elipse from ndoss ]]--

function Shape:drawEllipse(x,y,xradius,yradius,startAngle,endAngle,anticlockwise)
	local sides = (xradius + yradius) / 2  -- need a better default
	local dist  = 0

	-- handle missing entries
	if startAngle == nil then startAngle = 0 end
	if endAngle   == nil then endAngle   = 2*math.pi end

	-- Find clockwise distance (convert negative distances to positive)
	dist = endAngle - startAngle
	if (dist < 0) then
		dist = 2*math.pi - ((-dist) % (2*math.pi))
	end

	-- handle clockwise/anticlockwise
	if anticlockwise == nil or anticlockwise == false then
		-- CW
		-- Handle special case where mod of the two angles is equal but
		-- they're really not equal 
		if dist == 0 and startAngle ~= endAngle then
			dist = 2*math.pi
		end
	else
		-- CCW
		dist = dist - 2*math.pi

		-- Handle special case where mod of the two angles is equal but
		-- they're really not equal 
		if dist == 0 and startAngle ~= endAngle then
			dist = -2*math.pi
		end

	end
	self:beginPath()
	-- add the lines
	for i=0,sides do
		local angle = (i/sides) *  dist + startAngle
		self:lineTo(x + math.cos(angle) * xradius,
                         y + math.sin(angle) * yradius)
	end
	self:closePath()
	self:endPath()
	return self
end

--[[ draw arc from ndoss ]]--
function Shape:drawArc(centerX, centerY, radius, startAngle, endAngle, anticlockwise)
	return self:drawEllipse(centerX, centerY, radius, radius, startAngle ,endAngle, anticlockwise)
end

--[[ draw circle from ndoss ]]--

function Shape:drawCircle(centerX, centerY, radius, anticlockwise)
	return self:drawEllipse(centerX, centerY, radius, radius, 0, 2*math.pi, anticlockwise)
end


--[[
	SPRITE EXTENSIONS
]]--

--[[ anchor points ]]--

function Sprite:_testAnchor()
	if not self._anchorX then
		self._anchorX = 0
		self._anchorY = 0
		self._offX = 0
		self._offY = 0
	end
end

function Sprite:getAnchorPoint()
	self:_testAnchor()
	return self._anchorX, self._anchorY
end

function Sprite:setAnchorPoint(x, y)
	self:_testAnchor()
	y = y or x
	self._anchorX = x
	self._anchorY = y
	
	local angle = self:getRotation()
	self:_setRotation(0)
	local curX = self:get("x")
	local curY = self:get("y")
	
	self._offX = -self:getWidth() * self._anchorX
	self._offY = -self:getHeight() * self._anchorY
	
	self:_setRotation(angle)
	
	local cosine = math.cos(math.rad(angle))
	local sine = math.sin(math.rad(angle))
	
	local dx = -self._offX - (-self._offX * cosine + self._offY * sine)
	local dy = -self._offY - (-self._offY * cosine - self._offX * sine)
	
	self._offX = math.round(self._offX + dx)
	self._offY = math.round(self._offY + dy)
	
	local newX = curX + self._offX
	local newY = curY + self._offY
	
	self:_set("x", math.round(newX))
	self:_set("y", math.round(newY))
	
	return self
end

Sprite._setRotation = Sprite.setRotation

function Sprite:setRotation(angle)
	return self:set("rotation", angle)
end

Sprite._get = Sprite.get

function Sprite:get(param)
	self:_testAnchor()
	if Sprite.transform[param] ~= nil then
		return Sprite.transform[param]
	else
		if param == "x" then
			local x = self:_get("x")
			return x - self._offX
		elseif param == "y" then
			local y = self:_get("y")
			return y - self._offY
		else
			return self:_get(param)
		end
	end
end

function Sprite:getX()
	return self:get("x")
end

function Sprite:getY()
	return self:get("y")
end

function Sprite:getPosition()
	return self:get("x"), self:get("y")
end

--[[ z-axis manipulations ]]--

function Sprite:bringToFront()
	local parent = self:getParent()
	if parent then
		parent:addChild(self)
	end
	return self
end
 
function Sprite:sendToBack()
	local parent = self:getParent()
	if parent then
		parent:addChildAt(self, 1)
	end
	return self
end
 
function Sprite:setIndex(index)
	local parent = self:getParent()
	if parent then
		if index<parent:getChildIndex(self) then
			index=index-1
		end
		parent:addChildAt(self, index)
	end
	return self
end

function Sprite:getIndex()
	local parent = self:getParent()
	if parent then
		return parent:getChildIndex(self)
	end
end

function Sprite:addChildAtBack(child)
	self:addChildAt(child, 1)
	return self
end

function Sprite:addChildBefore(child, reference)
	local index = self:getChildIndex(reference)
	self:addChildAt(child, index-1)
	return self
end

function Sprite:addChildAfter(child, reference)
	local index = self:getChildIndex(reference)
	self:addChildAt(child, index+1)
	return self
end

function Sprite:replaceChild(existing, newchild)
	local index = self:getChildIndex(existing)
	self:removeChild(existing)
	self:addChildAt(newchild, index)
	return self
end

--[[ simple collision detection ]]--

function Sprite:collidesWith(sprite2)
	local x,y,w,h = self:getBounds(stage)
	local x2,y2,w2,h2 = sprite2:getBounds(stage)

	return not ((y+h < y2) or (y > y2+h2) or (x > x2+w2) or (x+w < x2))
end

function Sprite:ignoreTouchHandler(event)
	-- Simple handler to ignore touches on a sprite. This blocks touches
	-- from other objects below it.
	if self:hitTestPoint(event.touch.x, event.touch.y) then
		event:stopPropagation()
	end
	return self
end

function Sprite:ignoreMouseHandler(event)
	-- Simple handler to ignore mouse events on a sprite. This blocks mouse events
	-- from other objects below it.
	if self:hitTestPoint(event.x, event.y) then
		event:stopPropagation()
	end
	return self
end

function Sprite:ignoreTouches(event)
	-- Tell a sprite to ignore (and block) all mouse and touch events
	self:addEventListener(Event.MOUSE_DOWN, self.ignoreMouseHandler, self)
	self:addEventListener(Event.TOUCHES_BEGIN, self.ignoreTouchHandler, self)
	return self
end

function Sprite:setWidth(newWidth)
	-- Set a sprite's width using the scale property
	local x,y,width,height=self:getBounds(self)
	local newScale=newWidth/width
	self:setScaleX(newScale)
	return self
end
 
function Sprite:setHeight(newHeight)
	-- Set a sprite's height using the scale property
	local x,y,width,height=self:getBounds(self)
	local newScale=newHeight/height
	self:setScaleY(newScale)
	return self
end

--[[ skew transformation ]]--

Sprite.transform = {
	skew = 0,
	skewX = 0,
	skewY = 0
}

function Sprite:setSkew(xAng, yAng)
	return self	:set("skewX", xAng)
				:set("skewY", yAng)
end

function Sprite:setSkewX(xAng)
	return self:set("skewX", xAng)
end

function Sprite:setSkewY(yAng)
	return self:set("skewY", yAng)
end

function Sprite:getSkew()
	return self:get("skewX"), self:get("skewY")
end

function Sprite:getSkewX()
	return self:get("skewX")
end

function Sprite:getSkewY()
	return self:get("skewY")
end

--[[ flipping ]]--

function Sprite:flipHorizontal()
	self:setScaleX(-self:getScaleX())
	return self
end

function Sprite:flipVertical()
	self:setScaleY(-self:getScaleY())
	return self
end

--[[ hiding/showing visually and from touch/mouse events ]]--

function Sprite:hide()
	if not self.isHidden then
		self.xScale, self.yScale = self:getScale()
		self:setScale(0)
		self.isHidden = true
	end
	return self
end

function Sprite:isHidden()
	return self.isHidden
end

function Sprite:show()
	if self.isHidden then
		self:setScale(self.xScale, self.yScale)
	end
	return self
end

function Sprite:isVisibleDeeply()
	-- Answer true only if the sprite and all it's a parents are visible. Normally, isVisible() will
	-- return true even if a sprite is actually not visible on screen by wont of one of it's parents
	-- being made invisible.
	--
	local try=self
	while (try) do
		if  not(try:isVisible() and try:getAlpha()>0) then
			return false
		end
		try = try:getParent()
	end
	return true
end