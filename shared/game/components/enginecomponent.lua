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
end

function EngineComponent:LoadFromSubtypeInfo()
	if not self.subtype then
		error("No subtype set!")
	end

	local info = self:GetSubtypeInfo()
end
function EngineComponent:GetSubtypeInfo()
	return EngineComponent.static.subtypes[self.subtype_uid]
end



return EngineComponent