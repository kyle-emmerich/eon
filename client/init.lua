local Object = require 'shared.core.object'
local vec2 = require 'shared.core.vec2'
local uuid = require 'shared.core.uuid'
local Serializer = require 'shared.core.serializer'

local RenderSystem = require 'shared.core.rendersystem'

local PointLight = require 'shared.core.pointlight'

local System = require 'shared.game.system'

local Ship = require 'shared.game.ship'
local ShipHull = require 'shared.game.shiphull'

local client = {
	rendersystem = false

}

local ship = nil

function client.load(args)
	ShipHull.static.init()

	client.rendersystem = RenderSystem:new()
	client.rendersystem.current_system = System:new()

	local light = PointLight:new()
	light.color = {255, 255, 255, 255}
	local object = Object:new(vec2(100, 100), vec2(0, 0), 0, 0)
	object:SetRenderable(light)
	client.rendersystem.current_system:AddObject(object)

	
	ship = Ship:new(ShipHull.static.hulls[1])
	ship.state.pos = vec2(100, 100)
	ship:SetHull(ShipHull.static.hulls[1])
	ship.custom_color.r = 133
	ship.custom_color.g = 211
	ship.custom_color.b = 237

	client.rendersystem.current_system:AddObject(ship)
end

function client.update(dt)
	local torque = 7e3
	local force = 5e5
	if love.keyboard.isDown('a') then
		ship:ApplyTorque(-torque)
	end
	if love.keyboard.isDown('d') then
		ship:ApplyTorque(torque)
	end
	if love.keyboard.isDown('w') then
		ship:ApplyForce(vec2(math.cos(ship.rot_state.x) * force, math.sin(ship.rot_state.x) * force))
	end
	if love.keyboard.isDown('s') then
		ship.state.vel:iscale(0.95)
	end
	client.rendersystem.current_system:Update(dt)
end

function client.draw()	
	client.rendersystem:Render()
end

function client.quit()

end

function client.resize()
	client.rendersystem:Resize()
end


function client.run()
	love.math.setRandomSeed(os.time())
	for i = 1, 3 do love.math.random() end

	love.event.pump()

	client.load(arg)
	love.timer.step()

	collectgarbage('stop')

	local dt = 0
	while true do
		love.event.pump()
		for e, a, b, c, d in love.event.poll() do
			if e == "quit" then
				if not client.quit() then
					love.audio.stop()
					return
				end
			else 
				if client[e] then
					client[e](a,b,c,d)
				end
			end
		end
		love.timer.step()
		dt = love.timer.getDelta()

		client.update(dt)

		love.graphics.clear()
		love.graphics.origin()
		client.draw()
		love.graphics.present()

		collectgarbage()
		--love.timer.sleep(0.001)
	end

	collectgarbage()
	collectgarbage()
end

return client