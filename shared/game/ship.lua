local class = require 'shared.class'
local vec2 = require 'shared.core.vec2'
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
} Ship_data;

]]

local Ship = class('Ship', Object)
Ship.data = ffi.typeof('Ship_data')
function Ship:initialize(hull)
	Object.initialize(self, vec2(0, 0), vec2(0, 0), 0, 0)
	self.hull = hull
	self.components = {}
end

function Ship:AddComponent(component)
	table.insert(self.components, component)
	component.ship = self
end 

function Ship:Serialize(serializer)
	local data = Ship.data()

	data.object = Object.Serialize(self, serializer)
	data.hull_type = self.hull and self.hull.ID or 0
	data.name = serializer:PutString(self.name)

	data.components = serializer:PutArray(ShipComponent, self.components)

	return data
end

function Ship:Deserialize(serializer, data)
	Object.Deserialize(self, serializer, data.object)
	self.hull = ShipHull.static.hulls[data.hull_type]

	self.name = serializer:GetString(data.name)

	local components = serializer:GetArray(ShipComponent, data.components)
	for i, v in ipairs(components) do
		self:AddComponent(v)
	end
end

return Ship