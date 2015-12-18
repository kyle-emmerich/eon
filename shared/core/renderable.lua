local class = require 'shared.class'
local vec2 = require 'shared.core.vec2'
local Object = require 'shared.core.object'

local Renderable = class('Renderable')
function Renderable:initialize()
	self.parent = nil
	self.children = {}

	self.position = vec2(0, 0)
	self.rotation = 0

	self.color = { 255, 255, 255, 255 }
end

function Renderable:_render(object)
	love.graphics.rectangle('line', -24, -24, 48, 48)
	love.graphics.line(-24, -24, 24, 24)
	love.graphics.line(-24, 24, 24, -24)
end

function Renderable:RecalculateBounds()
	--stub
end

function Renderable:AddChild(child)
	if child.parent then
		child.parent:RemoveChild(child)
	end
	table.insert(self.children, child)
	child.parent = self
	self:RecalculateBounds()
end

function Renderable:RemoveChild(child)
	for i, v in ipairs(self.children) do
		if v == child then
			child.parent = false
			table.remove(self.children, i)
		end
	end
	self:RecalculateBounds()
end

function Renderable:Render(object, position, rotation)
	position = position or self.position
	rotation = rotation or self.rotation

	love.graphics.push()
	love.graphics.translate(position.x, position.y)
	love.graphics.rotate(rotation)
	self:_render(object)
	for i, v in ipairs(self.children) do
		v:Render(object)
	end
	love.graphics.pop()
end

return Renderable