local ffi = require('ffi')
ffi.cdef [[ 
typedef struct {
	float x;
	float y;
} vec2;

]]

local new_vec2 
local fn = {}
local vec2 = ffi.metatype('vec2', {
	__add = function(lhs, rhs)
		return new_vec2(lhs.x + rhs.x, lhs.y + rhs.y)
	end,
	__sub = function(lhs, rhs)
		return new_vec2(lhs.x - rhs.x, lhs.y - rhs.y)
	end,
	__mul = function(lhs, rhs)
		return new_vec2(lhs.x * rhs.x, lhs.y * rhs.y)
	end,
	__div = function(lhs, rhs)
		return new_vec2(lhs.x / rhs.x, lhs.y / rhs.y)
	end,
	__index = function(lhs, key)
		return fn[key]
	end,
	__tostring = function(t)
		return "vec2(" .. t.x .. ", " .. t.y .. ")"
	end
})
function fn:iadd(other)
	self.x = self.x + other.x
	self.y = self.y + other.y
	return self
end
function fn:isub(other)
	self.x = self.x - other.x
	self.y = self.y - other.y
	return self
end
function fn:imul(other)
	self.x = self.x * other.x
	self.y = self.y * other.y
	return self
end
function fn:isub(other)
	self.x = self.x / other.x
	self.y = self.y / other.y
	return self
end
function fn:set(x, y)
	self.x = x
	self.y = y
end
function fn:scale(x)
	return new_vec2(self.x * x, self.y * x)
end
function fn:iscale(x)
	self.x = self.x * x
	self.y = self.y * x
	return self
end
function fn:dot(other)
	return self.x * other.x + self.y * other.y
end
function fn:angle_to(other)
	return math.acos(self:dot(other))
end
function fn:sq_length()
	return self.x * self.x + self.y * self.y
end
function fn:length()
	return math.sqrt(self:sq_length())
end
function fn:unit()
	local len = self:length()
	return new_vec2(self.x / len, self.y / len)
end
function fn:angle()
	return math.atan2(self:yx())
end
function fn:copy()
	return new_vec2(self:xy())
end
function fn:from(other)
	self.x = other.x
	self.y = other.y
	return self
end
function fn.from_angle(angle)
	return new_vec2(math.cos(angle), math.sin(angle))
end
function fn:xy() return self.x, self.y end
function fn:xx() return self.x, self.x end
function fn:yx() return self.y, self.x end
function fn:yy() return self.y, self.y end

new_vec2 = setmetatable(fn, { 
	__call = function(t, x, y)
		local data = vec2()
		data.x = x or 0
		data.y = y or 0
		return data
	end
})

return new_vec2