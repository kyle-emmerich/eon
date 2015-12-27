local class = require 'shared.class'
local UI = require 'client.ui'
local Control = require 'client.ui.control'

local Button = class('Button', Control)
function Button:initialize()
	Control.initialize(self)
	self.contents = false

	self.color = UI.Colors.ButtonColor
	self.hover_color = UI.Colors.ButtonHoverColor
	self.active_color = UI.Colors.ButtonActiveColor

	self.text_color = UI.Colors.ButtonTextColor

	self.font = UI.Fonts.ButtonText
end

function Button:SetText(text)
	self.contents = text
end

function Button:_render()
	Control._render(self)
	
	love.graphics.setColor(255, 255, 255, 255)
	if type(self.contents) == 'string' then
		love.graphics.setColor(self.text_color)
		love.graphics.setFont(self.font)

		local ch = self.h - self.padding[2] - self.padding[4]
		local offset = ch / 2 - self.font:getHeight() / 2

		love.graphics.printf(self.contents, self.x + self.padding[1], self.y + offset, self.w - self.padding[1] - self.padding[3], 'center')
	else
		local scale = 1
		local w, h = self.contents:getWidth(), self.contents:getHeight()

		if self.radius then
			local dim = math.max(w, h)
			if dim > self.radius then
				scale = self.radius / dim
			end
		else
			local cw = self.w - self.padding[1] - self.padding[3]
			local ch = self.h - self.padding[2] - self.padding[4]
			local dim = 0
			if w > h and w > cw then
				scale = cw / w
			end
			if h > w and h > ch then
				scale = ch / h
			end
		end
		love.graphics.draw(self.contents, self.x + self.w / 2, self.y + self.h / 2, 0, scale, scale, w / 2, h / 2)
	end
end
 
return Button