
MenuScene = Core.class(Sprite)

-- Attribution
-- <a href="https://www.freepik.com/free-vector/ice-cream-shop-interior-with-fridge-tables_7588871.htm#query=ice%20cream%20shop&position=3&from_view=keyword&track=ais">Image by upklyak</a> on Freepik
-- Static setup

-- Load game assets (images, fonts, sounds and music)
function MenuScene.setup()
	
	--[[
		How to attribute it?
		
		For websites:
		
		Please, copy this code on your website to accredit the author:
		<a href="http://www.freepik.com">Designed by upklyak / Freepik</a>
		
		<a href="https://www.freepik.com/free-vector/magic-portal-mountain-top-alien-planet-surface-futuristic-landscape-background-with-glowing-entrance-rock-starry-sky-fantasy-book-computer-game-scene-cartoon-vector-illustration_12120251.htm#query=game%20background&position=1&from_view=search&track=ais">Image by upklyak</a> on Freepik
		
		<a href="https://www.freepik.com/free-vector/magic-portal-mountain-top-alien-planet-surface-futuristic-landscape-background-with-glowing-entrance-rock-starry-sky-fantasy-book-computer-game-scene-cartoon-vector-illustration_12120251.htm#query=game%20background&position=1&from_view=search&track=ais">Image by upklyak</a> on Freepik
	]]--
	
	MenuScene.texture_bg = Texture.new("images/background2.jpg")
	
	MenuScene.font_title = TTFont.new("fonts/firstfun.ttf", 40)
	MenuScene.font = TTFont.new("fonts/firstfun.ttf", 24)
end

-- Constructor
function MenuScene:init()
	application:setBackgroundColor(0x0000ff)
	
	self:addEventListener("enterEnd", self.enterEnd, self)
end

-- When menu scene is loaded
function MenuScene:enterEnd()
	
	self:draw_background()
	
	self:draw_title()
	
	self:draw_play()
	self:draw_highscore()

	self:addEventListener(Event.KEY_DOWN, self.onKeyDown, self)
end

-- Exit when back button is pressed
function MenuScene:onKeyDown(event)
	
	local keyCode = event.keyCode
	if (keyCode == KeyCode.BACK) then
		event:stopPropagation()
		application:exit()
	end
			
end

-- Draw menu background
function MenuScene:draw_background()
	local bg = Bitmap.new(MenuScene.texture_bg)
	bg:setPosition(-45, -30)
	bg:setScale(0.1)
	self:addChild(bg)
end

-- Draw game title
function MenuScene:draw_title() 
	local title = TextField.new(MenuScene.font_title, "Match-3 Game")
	title:setTextColor(0xffffcc)
	title:setPosition((application:getContentWidth() - title:getWidth()) * 0.5, 50)
	title:setShadow(2, 1, 0x000000)
	self:addChild(title)
end

-- Draw play option
function MenuScene:draw_play()

	local play = TextField.new(MenuScene.font, "Play")
	play:setTextColor(0xffff00)
	play:setPosition((application:getContentWidth() - play:getWidth()) * 0.5, 130)
	play:setShadow(2, 1, 0x000000)
	self:addChild(play)
end

-- Draw highscore option
function MenuScene:draw_highscore()

	local highscore = TextField.new(MenuScene.font, "Highscore")
	highscore:setTextColor(0xffff00)
	highscore:setPosition((application:getContentWidth() - highscore:getWidth()) * 0.5, 170)
	highscore:setShadow(2, 1, 0x000000)
	self:addChild(highscore)
end