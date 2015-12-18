local class = require 'shared.class'
local vec2 = require 'shared.core.vec2'
local deriv = require 'shared.core.deriv'
local ffi = require 'ffi'

local METERS_PER_PIXEL = 100000000
local GRAVITY = 9.8 / METERS_PER_PIXEL

ffi.cdef [[

typedef struct {
	deriv state;
	vec2 rot_state;

	double mass;
	double z;

} Object_data;

]]

local Object = class('Object')
Object.data = ffi.typeof('Object_data')
function Object:initialize(pos, vel, rot, rot_vel)
	self.state = deriv(pos or vec2(0,0), vel or vec2(0, 0))
	self.rot_state = vec2(rot or 0, rot_vel or 0)
	self.mass = 1

	self.orbiting = false
	self.orbital_period = 0
	self.orbital_eccentricity = 0
	self.orbital_major = 0
	self.orbital_minor = 0

	self.force = vec2(0, 0)
	self.torque = 0
	self.linear_accel = vec2(0, 0)
	self.rot_accel = 0

	self.renderable = false
	self.system = false

	self.z = 0
end

function Object:ApplyForce(vector)
	self.force:iadd(vector)
end
function Object:ApplyTorque(magnitude)
	self.torque = self.torque + magnitude
end

function Object:ApplyImpulse(vector)
	self.state.vel.x = self.state.vel.x + (vector.x / self.mass)
	self.state.vel.y = self.state.vel.y + (vector.y / self.mass)
end

function Object:ApplyAngularImpulse(magnitude)
	self.rot_state.y = self.rot_state.y + (magnitude / self.mass)
end

function Object:LinearAccel(dt)
	return self.linear_accel
end	
function Object:RotAccel(dt)
	return self.rot_accel
end

function Object:SetOrbiting(body, period, e)
	if not body then
		self.orbiting = false
	else
		self.orbiting = body
		
		local G = GRAVITY * body.mass
		local a = math.pow(((period / math.pi*2)^2 / G), 1/3)
		local c = e * aw
		local b = math.sqrt(a^2 - c^2)

		self.orbital_major = a
		self.orbital_minor = b
		self.orbital_period = period
		self.orbital_eccentricity = e
	end
end

function Object:SetRenderable(renderable)
	self.renderable = renderable
end
function Object:GetRenderable()
	return self.renderable
end

function Object:Update(dt)
	if self.orbiting then
		local t = love.timer.getTime()
		local theta = (math.pi * 2 * t) / self.orbital_period
		local d_theta = (math.pi * 2) / self.orbital_period
		local c = self.orbital_eccentricity * self.orbital_major
		self.state.pos.x = self.orbiting.state.pos.x + self.orbital_major * math.cos(theta) - c
		self.state.pos.y = self.orbiting.state.pos.y + self.orbital_minor * math.sin(theta)
		self.state.vel.x = self.orbiting.state.vel.x - self.orbital_major * math.sin(theta) * d_theta
		self.state.vel.y = self.orbiting.state.vel.y + self.orbital_minor * math.cos(theta) * d_theta
	else
		self.force:iscale(dt):iscale(1 / self.mass)
		self.linear_accel:iadd(self.force)
		self.torque = (self.torque * dt) / self.mass
		self.rot_accel = self.rot_accel + self.torque

		local steps = 4
		dt = dt / steps
		for i = 1, steps do
			deriv.step(self, dt)
		end

		self.force:iscale(0)
		self.torque = 0
		self.linear_accel:iscale(0)
		self.rot_accel = 0
	end
end

function Object:Render()
	if self.renderable then
		self.renderable:Render()
	end
end

function Object:Serialize(serializer)
	local data = Object.data()
	data.state = self.state
	data.rot_state = self.rot_state

	data.mass = self.mass
	data.z = self.z

	return data
end

function Object:Deserialize(serializer, data)
	self.state = data.state
	self.rot_state = data.rot_state

	self.mass = data.mass
	self.z = data.z
end

return Object