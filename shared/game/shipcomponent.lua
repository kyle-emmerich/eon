local class = require 'shared.class'
local Serializer = require 'shared.core.serializer'

local ffi = require 'ffi'
ffi.cdef [[

typedef struct {
	ID type;
	char subtype_uid[8];
	uint32_t health;
	uint32_t mount;

	bool active;
	char tag[31];

	uint8_t metadata[32];
} ShipComponent_data;

]]

local ShipComponent = class('ShipComponent') --, InventoryItem)
ShipComponent.data = ffi.typeof('ShipComponent_data')
ShipComponent.static.Types = {
	Engine = 1,
	Armor = 2,
	Cargo = 3,
	AttitudeControl = 4,
	FlightComputer = 5,
	PowerGenerator = 6,
	PowerWiring = 7,
	Battery = 8,

}
ShipComponent.static.components = {}
ShipComponent.static.init = function()
	local files = love.filesystem.getDirectoryItems('shared/game/components')
	for i, v in ipairs(files) do
		if love.filesystem.isFile(v) and v:sub(-4) == '.lua' then
			local comp_type = love.filesystem.load(v)(ShipComponent)
			if comp_type.static.init then
				comp_type.static.init()
			end
		end
	end
end
function ShipComponent:initialize()
	self.type = false
	self.subtype = false
	self.health = false
	self.mount = false

	self.active = false
	self.tag = false
end

function ShipComponent:_serialize_metadata(serializer, data)
	ffi.fill(data.metadata, 128, 0)
end

function ShipComponent:_deserialize_metadata(serializer, metadata)

end

function ShipComponent:LoadFromSubtypeInfo()
	error('LoadFromSubtypeInfo not implemented on ' .. self.class.name)
end
function ShipComponent:GetSubtypeInfo()
	return nil
end

function ShipComponent:GetName()
	return self:GetSubtypeInfo().name
end
function ShipComponent:GetDescription()
	return self:GetSubtypeInfo().description
end
function ShipComponent:GetMass()
	return self:GetSubtypeInfo().mass
end

function ShipComponent:Serialize(serializer)
	local data = ShipComponent.data()
	data.type = self.type
	data.subtype_uid = self.subtype_uid
	data.health = self.health
	data.mount = self.mount

	data.active = self.active
	data.tag = self.tag

	self:_serialize_metadata(data)

	return data
end

function ShipComponent:Deserialize(serializer, data)
	self.type = data.type
	self.subtype_uid = ffi.string(data.subtype_uid, 8)
	self.health = data.health
	self.mount = data.mount

	self.active = data.active
	self.tag = ffi.string(data.tag)

	self:_deserialize_metadata(serializer, data.metadata)
end

return ShipComponent