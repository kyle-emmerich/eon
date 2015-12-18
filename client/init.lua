local Object = require 'shared.core.object'
local vec2 = require 'shared.core.vec2'
local Serializer = require 'shared.core.serializer'

local Ship = require 'shared.game.ship'
local ShipHull = require 'shared.game.shiphull'

local client = {}

local ship = nil

function client.load(args)
	ShipHull.static.init()
	ship = Ship:new(ShipHull.static.hulls[1])
	ship:SetHull(ShipHull.static.hulls[1])
	ship.custom_color.r = 133
	ship.custom_color.g = 211
	ship.custom_color.b = 237
end

function client.update(dt)
	local torque = 3e7
	local force = 5e8
	if love.keyboard.isDown('a') then
		ship:ApplyTorque(-torque)
	end
	if love.keyboard.isDown('d') then
		ship:ApplyTorque(torque)
	end
	if love.keyboard.isDown('w') then
		
		ship:ApplyForce(vec2(math.cos(ship.rot_state.x) * force, math.sin(ship.rot_state.x) * force))
	end
	ship:Update(dt)
end

function client.draw()	
	ship:Render()
end

function client.quit()

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
		love.timer.sleep(0.001)
	end
end

return client