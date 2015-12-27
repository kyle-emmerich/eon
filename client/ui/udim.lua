local class = require 'shared.class'

local UDim = class('UDim')
function UDim:initialize(x, ox, y, oy, w, ow, h, oh)
	self.x = x or 0
	self.ox = ox or 0
	self.y = y or 0
	self.oy = oy or 0
	self.w = w or 0
	self.ow = ow or 0
	self.h = h or 0
	self.oh = oh or 0
end
function UDim:Evaluate(parent, child)
	if not parent then
		return
	end
	if parent.dirty then
		parent.udim:Evaluate(parent.parent, parent)
	end
	local px = parent.x
	local py = parent.y
	local pw = parent.w
	local ph = parent.h
	child.x = px + (pw * self.x) + self.ox + parent.padding[1] + child.margin[1]
	child.y = py + (ph * self.y) + self.oy + parent.padding[2] + child.margin[2]
	child.w = (pw * self.w) + self.ow - parent.padding[1] - parent.padding[3] - child.margin[3] - child.margin[1]
	child.h = (ph * self.h) + self.oh - parent.padding[4] - parent.padding[4] - child.margin[4] - child.margin[2]
	child.dirty = false
end

return UDim