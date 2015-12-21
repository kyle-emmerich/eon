local class = require 'shared.class'
local vec2 = require 'shared.core.vec2'
local Object = require 'shared.core.object'
local Renderable = require 'shared.core.renderable'

local System = class('System')
function System:initialize()
	self.objects = {}
end

function System:SortZ()
	table.sort(self.objects, function(a, b) return a.z < b.z end)
end

function System:AddObject(object, no_sort)
	table.insert(self.objects, object)
	if not no_sort then
		self:SortZ()
	end
end

function System:RemoveObject(object)
	for i, v in ipairs(self.objects) do
		if v == object then
			object.system = false
			table.remove(self.objects, i)
		end
	end
end

function System:Update(dt)
	for i, v in ipairs(self.objects) do
		v:Update(dt)
	end
end

function System:Render(rendersystem)
	--todo: replace this with better optimized version
	for i, v in ipairs(self.objects) do
		v:Render(rendersystem)
	end
end

function System:RenderLight(rendersystem)
	for i, v in ipairs(self.objects) do
		v:RenderLight(rendersystem)
	end
end

return System