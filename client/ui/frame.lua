local class = require 'shared.class'
local UI = require 'client.ui'
local Control = require 'client.ui.control'
local Utility = require 'shared.core.utility'
local dropshadow = require 'client.ui.dropshadow'

local Frame = class('Frame', Control)
function Frame:initialize()
	Control.initialize(self)
	self.draggable = true
	self.titlebar_color = UI.Colors.FrameTitlebarColor
	self.titlebar_height = 32
	self.titlebar_text = ""
	self.titlebar_text_color = UI.Colors.FrameTitlebarTextColor
	self.titlebar_text_font = UI.Fonts.FrameTitlebarText

	self.resize_width = 5
	self.resizable = { true, true, true, true }
	self.resizing = { false, false, false, false }
	self.min_size = { 100, 100 }

	self.original_rect = { 0, 0, 0, 0 }

	self:SetPaddings(0, self.titlebar_height, 0, 0)
end

function Frame:SetText(text)
	self.titlebar_text = text
end

function Frame:OnDragStart(x, y)
	local rx, ry = x - self.x, y - self.y
	print(rx, ry, self.x, self.y, self.w, self.h)
	if rx > 0 and rx < self.resize_width then
		self.resizing[1] = true
	end
	if ry > 0 and ry < self.resize_width then
		self.resizing[2] = true
	end
	if rx > self.w - self.resize_width and rx < self.w then
		self.resizing[3] = true
	end
	if ry > self.h - self.resize_width and ry < self.h then
		self.resizing[4] = true
	end

	self.original_rect[1] = self.udim.ox
	self.original_rect[2] = self.udim.oy
	self.original_rect[3] = self.udim.ow
	self.original_rect[4] = self.udim.oh

	return true
end
function Frame:OnDragStop()
	self.resizing[1] = false
	self.resizing[2] = false
	self.resizing[3] = false
	self.resizing[4] = false
end

function Frame:DragTo(x, y, dx, dy)
	local dragging = true
	if self.resizing[1] then
		--todo: implement minimum size
		self.udim.ow = self.original_rect[3] - dx
		self.udim.ox = self.original_rect[1] + dx
		dragging = false
	end
	if self.resizing[2] then
		self.udim.oh = self.original_rect[4] - dy
		self.udim.oy = self.original_rect[2] + dy
		dragging = false
	end
	if self.resizing[3] then
		self.udim.ow = self.original_rect[3] + dx
		dragging = false
	end
	if self.resizing[4] then
		self.udim.oh = self.original_rect[4] + dy
		dragging = false
	end

	if dragging then
		self.udim.ox = self.original_rect[1] + dx
		self.udim.oy = self.original_rect[2] + dy
	end
	self:Invalidate()
end	

function Frame:_render()
	love.graphics.setColor(self.color)
	love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)

--	love.graphics.setColor(255, 255, 255, 255)
--	love.graphics.draw(dropshadow, 0, self.titlebar_height - 2, 0, self.w, 8)

	love.graphics.setColor(self.titlebar_color)
	love.graphics.rectangle('fill', self.x, self.y, self.w, self.titlebar_height)

	love.graphics.setColor(self.titlebar_text_color)
	love.graphics.setFont(self.titlebar_text_font)
	local offset = self.titlebar_height / 2 - self.titlebar_text_font:getHeight() / 2
	love.graphics.print(self.titlebar_text, math.floor(self.x + offset), math.floor(self.y + offset))
end

return Frame