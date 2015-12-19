local vec2 = require 'shared.core.vec2'
local ffi = require 'ffi'

ffi.cdef [[
	
typedef struct {
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

new_deriv = setmetatable(fn, {
	__call = function(t, pos, vel)
		t = deriv()
		t.pos = pos:copy()
		t.vel = vel:copy()
		return t
	end,
})

local d0 = new_deriv(vec2(0, 0), vec2(0, 0))
local d1 = new_deriv(vec2(0, 0), vec2(0, 0))
local d2 = new_deriv(vec2(0, 0), vec2(0, 0))
local d3 = new_deriv(vec2(0, 0), vec2(0, 0))
local d4 = new_deriv(vec2(0, 0), vec2(0, 0))

local dv0 = vec2(0, 0)
local dv1 = vec2(0, 0)
local dv2 = vec2(0, 0)
local dv3 = vec2(0, 0)
local dv4 = vec2(0, 0)

function fn.compute(out, obj, state, accel_fn, dt, d)
	out.pos:from(d.vel):iscale(dt):iadd(state.vel)
	out.vel:from(accel_fn(obj, dt))
	return out
end
function fn.compute_vec2(out, obj, state, accel_fn, dt, d)
	out.x = (d.y * dt) + state.y
	out.y = accel_fn(obj, dt)
	return out
end

function fn.step(obj, dt)
	d1 = deriv.compute(d1, obj, obj.state, obj.LinearAccel, dt * 0.0, d0)
	d2 = deriv.compute(d2, obj, obj.state, obj.LinearAccel, dt * 0.5, d1)
	d3 = deriv.compute(d3, obj, obj.state, obj.LinearAccel, dt * 0.5, d2)
	d4 = deriv.compute(d4, obj, obj.state, obj.LinearAccel, dt * 1.0, d3)

	d2:iadd(d3):iscale(2)
	d4:iadd(d2):iscale(0.1666666666)
	d4:iscale(dt)
	obj.state:iadd(d4)

	dv1 = deriv.compute_vec2(dv1, obj, obj.rot_state, obj.RotAccel, dt * 0.0, dv0)
	dv2 = deriv.compute_vec2(dv2, obj, obj.rot_state, obj.RotAccel, dt * 0.5, dv1)
	dv3 = deriv.compute_vec2(dv3, obj, obj.rot_state, obj.RotAccel, dt * 0.5, dv2)
	dv4 = deriv.compute_vec2(dv4, obj, obj.rot_state, obj.RotAccel, dt * 1.0, dv3)

	dv2:iadd(dv3):iscale(2)
	dv4:iadd(dv2):iscale(0.1666666666)
	dv4:iscale(dt)
	obj.rot_state:iadd(dv4)
end



return new_deriv