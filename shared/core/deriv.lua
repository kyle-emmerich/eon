local vec2 = require 'shared.core.vec2'
local ffi = require 'ffi'

ffi.cdef [[
	
typedef struct deriv_ {
	vec2 pos;
	vec2 vel;
} deriv;

]]

local new_deriv
local fn = {}
local deriv = ffi.metatype('deriv', {
	__add = function (t, other)
		return new_deriv(
			t.pos + other.pos,
			t.vel + other.vel
		)
	end,
	__sub = function (t, other)
		return new_deriv(
			t.pos + other.pos,
			t.vel + other.vel
		)
	end,
	__mul = function (t, scalar)
		return new_deriv(
			t.pos:scale(scalar),
			t.vel:scale(scalar)
		)
	end,
	__index = function(t, key)
		return fn[key]
	end
})
function fn:iadd(other)
	self.pos:iadd(other.pos)
	self.vel:iadd(other.vel)
	return self
end
function fn:isub(other)
	self.pos:isub(other.pos)
	self.vel:isub(other.vel)
	return self
end
function fn:iscale(other)
	self.pos:iscale(other)
	self.vel:iscale(other)
	return self
end
function fn:copy()
	return deriv(
		self.pos:copy(),
		self.vel:copy()
	)
end
function fn.compute(obj, state, accel_fn, dt, d)
	new_vel = (d.vel:scale(dt)) + state.vel
	return new_deriv(new_vel, accel_fn(obj, dt))
end
function fn.compute_vec2(obj, state, accel_fn, dt, d)
	new_vel = (d.y * dt) + state.y
	return vec2(new_vel, accel_fn(obj, dt))
end

function fn.step(obj, dt)
	local d1 = deriv.compute(obj, obj.state, obj.LinearAccel, dt * 0.0, deriv.d0)
	local d2 = deriv.compute(obj, obj.state, obj.LinearAccel, dt * 0.5, d1)
	local d3 = deriv.compute(obj, obj.state, obj.LinearAccel, dt * 0.5, d2)
	local d4 = deriv.compute(obj, obj.state, obj.LinearAccel, dt * 1.0, d3)

	d2:iadd(d3):iscale(2)
	d4:iadd(d2):iscale(1/6)
	d4:iscale(dt)
	obj.state:iadd(d4)

	d1 = deriv.compute_vec2(obj, obj.rot_state, obj.RotAccel, dt * 0.0, vec2(0, 0))
	d2 = deriv.compute_vec2(obj, obj.rot_state, obj.RotAccel, dt * 0.5, d1)
	d3 = deriv.compute_vec2(obj, obj.rot_state, obj.RotAccel, dt * 0.5, d2)
	d4 = deriv.compute_vec2(obj, obj.rot_state, obj.RotAccel, dt * 1.0, d3)

	d2:iadd(d3):iscale(2)
	d4:iadd(d2):iscale(1/6)
	d4:iscale(dt)
	obj.rot_state:iadd(d4)
end

new_deriv = setmetatable(fn, {
	__call = function(t, pos, vel)
		t = deriv()
		t.pos = pos:copy()
		t.vel = vel:copy()
		return t
	end,
})

new_deriv.d0 = new_deriv(vec2(0, 0), vec2(0, 0))

return new_deriv