local class = require 'shared.class'
local ffi = require 'ffi'

ffi.cdef [[

typedef struct {
	
} ShipComponent_data;

]]

local ShipComponent = class('ShipComponent')
ShipComponent.data = ffi.typeof('ShipComponent_data')
function ShipComponent:initialize()

end

return ShipComponent