local class = require 'shared.class'

local dx, dy, dz = 1.0, 0.0, -0.0
local len = math.sqrt(dx * dx + dy * dy + dz * dz)
dx = dx / len
dy = dy / len
dz = dz / len

local vertex_code = [[

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
	return transform_projection * vertex_position;
}
		]]

local RenderSystem = class('RenderSystem')
function RenderSystem:initialize()
	self.current_system = false

	self.diffuse = false
	self.info = false
	self.velocity = false
	self.light = false
	self.final = false

	self.size = { 1, 1 }

	self.shader_lit = love.graphics.newShader(
		vertex_code,
		love.filesystem.read('shared/asset/shader/lit.fs')
	)
	self.shader_point = false
	self.shader_directional = love.graphics.newShader(
		vertex_code,
		love.filesystem.read('shared/asset/shader/directional.fs')
	)
	self.shader_combine = love.graphics.newShader(
		vertex_code,
		love.filesystem.read('shared/asset/shader/combine.fs')
	)
	self.shader_motionblur = love.graphics.newShader(
		vertex_code,
		love.filesystem.read('shared/asset/shader/motionblur.fs')
	)

	self:Resize()
end

function RenderSystem:Resize()
	self.diffuse = love.graphics.newCanvas()
	self.info = love.graphics.newCanvas()
	self.velocity = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), 'rg16f')
	self.light = love.graphics.newCanvas()
	self.final = love.graphics.newCanvas()
	self.final:setWrap('clamp', 'clamp')

	self.size = { love.graphics.getWidth(), love.graphics.getHeight() }
end

function RenderSystem:Render()
	if self.current_system then
		love.graphics.setBlendMode('alpha', 'alphamultiply')
		love.graphics.setCanvas(self.diffuse, self.info, self.velocity)
		love.graphics.clear()
		
		love.graphics.setShader(self.shader_lit)
		self.current_system:Render(self)

		love.graphics.setCanvas(self.light)
		love.graphics.clear(60, 60, 60, 0)
		love.graphics.setBlendMode('add', 'premultiplied')
		love.graphics.setShader(self.shader_directional)
		self.shader_directional:send('light_dir', {dx, dy, dz})
		self.shader_directional:sendColor('light_color', {255, 255, 255, 255})
		self.shader_directional:send('specularity', 256.0)
		
		love.graphics.draw(self.info)


		
		love.graphics.setCanvas(self.final)
		love.graphics.clear()
		love.graphics.setShader(self.shader_combine)
		love.graphics.setBlendMode('alpha', 'premultiplied')
		self.shader_combine:send('canvas_light', self.light)
		self.shader_combine:send('canvas_info', self.info)
		love.graphics.draw(self.diffuse)
		love.graphics.setShader()

		love.graphics.setCanvas()
		love.graphics.clear()
		love.graphics.setShader(self.shader_motionblur)

		self.shader_motionblur:send('canvas_velocity', self.velocity)
		self.shader_motionblur:send('canvas_size', self.size)
		love.graphics.setBlendMode("replace")
		love.graphics.draw(self.final)

	end

	love.graphics.setShader()
	love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
end

return RenderSystem