local ShipComponent = (...)
local class = require 'shared.class'

local ffi = require 'ffi'
ffi.cdef [[

typedef struct {
	
} EngineComponent_metadata;

]]

local EngineComponent = class('EngineComponent', ShipComponent)
ShipComponent.static.components[ShipComponent.static.Types.Engine] = EngineComponent
EngineComponent.metadata = ffi.typeof('EngineComponent_metadata')
EngineComponent.static.subtypes = {}
EngineComponent.static.init = function()
	love.filesystem.load('shared/asset/components/engines.lua')(function(t)
		EngineComponent.static.subtypes[t.uid] = t
	end)
end
function EngineComponent:initialize()
	ShipComponent.initialize(self)

	self.thrust = 0
end

function EngineComponent:GetSubtypeInfo()
	return EngineComponent.static.subtypes[self.subtype_uid] or {}
end
function EngineComponent:LoadFromSubtypeInfo()
	local info = ShipComponent.LoadFromSubtypeInfo(self)
	self.thrust = info.thrust or 1

	return info
end

function EngineComponent:Apply(ship)
	ShipComponent.Apply(self, ship)

	ship.thrust = ship.thrust + self.thrust
end

return EngineComponent