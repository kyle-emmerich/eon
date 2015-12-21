local class = require 'shared.class'
local Renderable = require 'shared.core.renderable'

local PointLight = class('PointLight', Renderable)
function PointLight:initialize()
	Renderable.initialize(self)
	self.radius = 300
	self.z = 20
end

function PointLight:_render(rendersystem, object)
	--nothing
end
function PointLight:RenderLight(rendersystem, object)
	local px, py = self.position.x, self.position.y
	px = px + object.state.pos.x
	py = py + object.state.pos.y
	rendersystem.shader_point:send('light_pos', { px, py, self.z })
	rendersystem.shader_point:sendColor('light_color', self.color)
	rendersystem.shader_point:send('light_radius', self.radius)

	print(px, py)
	--love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.circle('fill', px, py, self.radius * 1.2, 32)
end

return PointLight