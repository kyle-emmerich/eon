local ShipComponent = (...)
local class = require 'shared.class'

local ffi = require 'ffi'
ffi.cdef [[

typedef struct {
	
} AttitudeControlComponent_metadata;

]]

local AttitudeControlComponent = class('AttitudeControlComponent', ShipComponent)
ShipComponent.static.components[ShipComponent.static.Types.AttitudeControl] = AttitudeControlComponent
AttitudeControlComponent.metadata = ffi.typeof('AttitudeControlComponent_metadata')
AttitudeControlComponent.static.subtypes = {}
AttitudeControlComponent.static.init = function()
	love.filesystem.load('shared/asset/components/attitudecontrols.lua')(function(t)
		AttitudeControlComponent.static.subtypes[t.uid] = t
	end)
end
function AttitudeControlComponent:initialize()
	ShipComponent.initialize(self)

	self.torque = 0
end

function AttitudeControlComponent:GetSubtypeInfo()
	return AttitudeControlComponent.static.subtypes[self.subtype_uid] or {}
end
function AttitudeControlComponent:LoadFromSubtypeInfo()
	local info = ShipComponent.LoadFromSubtypeInfo(self)
	self.torque = info.torque or 0

	return info
end

function AttitudeControlComponent:Apply(ship)
	ShipComponent.Apply(self, ship)

	ship.torque = ship.torque + self.torque
end

return AttitudeControlComponent