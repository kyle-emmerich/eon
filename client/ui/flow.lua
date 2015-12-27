local class = require 'shared.class'
local Control = require 'client.ui.control'
local UI = require 'client.ui'

local Flow = class('Flow', Control)
function Flow:initialize()
	Control.initialize(self)
end

function Flow:Layout()
	Control.Layout(self)

	local x = self.padding[1]
	local h = 0
	for i, v in ipairs(self.children) do
		x = x + v.margin[1]
		v.udim.x = 0
		v.udim.ox = x
		v.udim.y = 0
		v.udim.oy = self.padding[2]
		x = x + v.w + v.margin[2]

		h = math.max(h, v.h)
	end

	self.w = x + self.padding[3]
	self.h = h + self.padding[2] + self.padding[4]
end

function Flow:_render()
end

return Flow