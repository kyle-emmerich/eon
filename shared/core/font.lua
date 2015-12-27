local class = require 'shared.class'

local Font = class('Font')
function Font:initialize(path)
	self.path = path

	self.weights = {}
end

function Font:_create(weight, style, size)
	local path = self.path .. weight .. '-' .. style .. '.ttf'
	local style_table = self.weights[weight] or {}
	self.weights[weight] = style_table

	local size_table = style_table[style] or {}
	style_table[style] = size_table

	size_table[size] = love.graphics.newFont(path, size)

	return size_table[size]
end

function Font:Get(weight, style, size)
	if self.weights[weight] and self.weights[weight][style] and self.weights[weight][style][size] then
		return self.weights[weight][style][size]
	end
	return self:_create(weight, style, size)
end

return Font