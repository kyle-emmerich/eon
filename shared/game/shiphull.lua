local class = require 'shared.class'

local ShipHull = class('ShipHull')
ShipHull.static.hulls = {}
function ShipHull:initialize(id)
	ShipHull.static.hulls[id] = self

	self.image = false
	self.mass = 1
end

return ShipHull