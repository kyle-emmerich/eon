local class = require 'shared.class'
local Control = require 'client.ui.control'
local UI = require 'client.ui'

local Stack = class('Stack', Control)
function Stack:initialize()
	Control.initialize(self)
end

function Stack:Layout()
	Control.Layout(self)

	local y = self.padding[2]
	local w = 0
	for i, v in ipairs(self.children) do
		v.udim.x = 0
		v.udim.ox = self.padding[1]
		v.udim.y = 0
		v.udim.oy = y
		y = y + v.h + v.margin[2] + v.margin[4]

		w = math.max(w, v.w)
	end

	self.h = y + self.padding[4]	
end

function Stack:_render()
end

return Stack