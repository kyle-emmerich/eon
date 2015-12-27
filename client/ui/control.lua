local class = require 'shared.class'
local Utility = require 'shared.core.utility'
local UI = require 'client.ui'
local UDim = require 'client.ui.udim'

local Control = class('Control')
function Control:initialize()
	self.x = 0
	self.y = 0
	self.w = 0
	self.h = 0

	self.udim = UDim:new(0, 0, 0, 0, 1, 0, 1, 0)
	self.dirty = true

	self.children = {}
	self.parent = false

	self.hovered = false
	self.active = false
	self.visible = true
	self.focused = false
	self.can_focus = false
	self.mousedown = {}

	self.dock = false
	self.dock_x = 0
	self.dock_y = 0
	self.dock_width = 0.25
	self.dock_height = 0.25

	self.margin = { 0, 0, 0, 0 }
	self.padding = { 0, 0, 0, 0 }

	self.hover_color = UI.Colors.Hovered
	self.color = UI.Colors.Normal
	self.active_color = self.color
end

function Control:SetParent(parent)
	if self.parent then
		for i, v in ipairs(self.parent.children) do
			if v == self then
				table.remove(self.parent.children, i)
				break
			end
		end
	end
	self.parent = parent
	if self.parent then
		table.insert(self.parent.children, self)
	end
	self.dirty = true
	self.udim:Evaluate(self.parent, self)
end

function Control:Invalidate()
	self.dirty = true
	for i, v in ipairs(self.children) do
		v:Invalidate()
	end
end

function Control:Layout()
	if self.dirty then
		self.udim:Evaluate(self.parent, self)
	end
end

function Control:SetSize(w, h)
	self.udim.w = 0
	self.udim.h = 0
	self.udim.ow = w
	self.udim.oh = h
end
function Control:SetWidth(w)
	self.udim.w = 0
	self.udim.ow = w
end
function Control:SetHeight(h)
	self.udim.h = 0
	self.udim.oh = h
end

function Control:GetInsidePosition()
	local x, y = self:GetPosition()
	return x + self.padding[1], y + self.padding[3]
end

function Control:DragTo(x, y)
	self.udim.ox = x
	self.udim.oy = y
	self:Invalidate()
end
function Control:OnDragStart()
	return true
end
function Control:OnDragStop()

end

function Control:SetMargins(left, top, right, bottom)
	self.margin[1] = left
	self.margin[2] = top
	self.margin[3] = right
	self.margin[4] = bottom
end
function Control:SetMargin(m)
	self.margin[1] = m
	self.margin[2] = m
	self.margin[3] = m
	self.margin[4] = m
end

function Control:SetPaddings(left, top, right, bottom)
	self.padding[1] = left
	self.padding[2] = top
	self.padding[3] = right
	self.padding[4] = bottom
end
function Control:SetPadding(p)
	self.padding[1] = p
	self.padding[2] = p
	self.padding[3] = p
	self.padding[4] = p
end

function Control:IsPointInside(px, py)
	local x, y = self.x, self.y
	local w, h = self.w, self.h
	return Utility.PointInsideRect(x, y, w, h, px, py)
end

function Control:OnMouseHover()
	self.hovered = true
end

function Control:OnMouseLeave()
	self.hovered = false
end

function Control:OnFocus(focused)
	self.focused = focused
end

function Control:OnKeyDown(key, scancode, is_repeat)

end
function Control:OnKeyUp(key, scancode, is_repeat)

end
function Control:OnTextInput(text)

end

function Control:OnMouseDown(x, y, idx)
	if UI.hovered == self then
		self.mousedown[idx] = true
		self.active = true
	end

	for i, v in ipairs(self.children) do
		v:OnMouseDown(x, y, idx)
	end
end
function Control:OnMouseUp(x, y, idx)
	if UI.hovered == self and self.mousedown[idx] then
		self:OnMouseClick(idx)
	end
	self.mousedown[idx] = false
	self.active = false

	for i, v in ipairs(self.children) do
		v:OnMouseUp(x, y, idx)
	end
end
function Control:OnMouseClick(idx)
	if self == UI.root then return end
end

function Control:OnResized()
	if self.dock and self.parent then
		self.x = self.parent.w * self.dock_x + self.margin[1]
		self.y = self.parent_h * self.dock_y + self.margin[2]
		self.w = self.parent_w * self.dock_width - self.margin[3] - self.margin[1]
		self.h = self.parent_h * self.dock_height - self.margin[4] - self.margin[2]
	end
	for i, v in ipairs(self.children) do
		v:OnResized()
	end
end

function Control:Update(dt)
	self:Layout()
	if self:IsPointInside(love.mouse.getPosition()) then
		UI.hovered = self
	end

	for i, v in ipairs(self.children) do
		v:Update(dt)
	end
end

function Control:_render()
	love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

function Control:Render()
	if not self.visible then
		return
	end

	love.graphics.setColor(self.color)
	if self.hovered then
		love.graphics.setColor(self.hover_color)
	end
	if self.active then
		love.graphics.setColor(self.active_color)
	end

	if self ~= UI.root then
		self:_render()
	end

	for i, v in ipairs(self.children) do
		v:Render()
	end
end

return Control