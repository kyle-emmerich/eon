local class = require 'shared.class'
local Renderable = require 'shared.core.renderable'

local ShipHull = class('ShipHull', Renderable)
ShipHull.static.hulls = {}
ShipHull.static.init = function()
	ShipHull.static.shader = love.graphics.newShader(
		[[
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
	return transform_projection * vertex_position;
}
		]],
		love.filesystem.read('shared/asset/shader/lit.fs')
	)
	require 'shared.asset.shiphulls'
end
function ShipHull:initialize(data)
	Renderable.initialize(self)
	ShipHull.static.hulls[data.id] = self

	self.name = data.name or false
	self.path = data.path or false
	self.mass = data.mass or false
	self.scale = data.scale or false

	if not self.path then
		error("No path provided for ShipHull")
	end

	self.diffuse = love.graphics.newImage(self.path .. '/diffuse.png')
	self.custom = love.graphics.newImage(self.path .. '/custom.png')
	self.normal = love.graphics.newImage(self.path .. '/normal.png')
	self.occlusion = love.graphics.newImage(self.path .. '/occlusion.png')
end

function ShipHull:_render(ship)
	love.graphics.scale(self.scale)

	local shader = ShipHull.static.shader
	love.graphics.setShader(shader)
	shader:send('normal_tex', self.normal)
	shader:send('custom_tex', self.custom)
	shader:send('occlusion_tex', self.occlusion)

	local custom_color = ship.custom_color
	shader:sendColor('custom_color', { custom_color.r, custom_color.g, custom_color.b, 255 })

	shader:sendColor('ambient_light', { 50, 50, 50, 0 })

	shader:send('rotation', ship.rot_state.x)

	love.graphics.draw(self.diffuse, 0, 0, 0, 1, 1, self.diffuse:getWidth()/2, self.diffuse:getHeight()/2)


	love.graphics.setShader()
end

return ShipHull