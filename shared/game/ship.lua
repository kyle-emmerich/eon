local class = require 'shared.class'
local vec2 = require 'shared.core.vec2'
local color = require 'shared.core.color'
local Object = require 'shared.core.object'
local ShipHull = require 'shared.game.shiphull'
local ShipComponent = require 'shared.game.shipcomponent'

local ffi = require 'ffi'
ffi.cdef [[

typedef struct {
	Object_data object;

	ID hull_type;
	string name;
	array components;

	color custom_color;
} Ship_data;

]]

local Ship = class('Ship', Object)
Ship.data = ffi.typeof('Ship_data')
function Ship:initialize()
	Object.initialize(self, vec2(0, 0), vec2(0, 0), 0, 0)
	self.hull = false
	self.renderable = false
	self.components = {}

	self.custom_color = color{ 255, 255, 255, 255 }
end

function Ship:AddComponent(component)
	table.insert(self.components, component)
	component.ship = self

	self:RecalculateMass()
end 

function Ship:SetHull(hull)
	self.hull = hull
	self.renderable = hull

	self:RecalculateMass()
end

function Ship:Update(dt)
	Object.Update(self, dt)
	self.rot_state.y = self.rot_state.y * 0.95
end

function Ship:RecalculateMass()
	self.mass = self.hull.mass

	--add component masses
end

function Ship:Serialize(serializer)
	local data = Ship.data()

	data.object = Object.Serialize(self, serializer)
	data.hull_type = self.hull and self.hull.ID or 0
	data.name = serializer:PutString(self.name)

	data.components = serializer:PutArray(ShipComponent, self.components)

	data.custom_color = self.custom_color

	return data
end

function Ship:Deserialize(serializer, data)
	Object.Deserialize(self, serializer, data.object)
	self:SetHull(ShipHull.static.hulls[data.hull_type])

	self.name = serializer:GetString(data.name)

	self.custom_color = data.custom_color

	local components = serializer:GetArray(ShipComponent, data.components)
	for i, v in ipairs(components) do
		self:AddComponent(v)
	end
end

return Ship