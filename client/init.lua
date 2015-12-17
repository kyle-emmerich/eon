local Object = require('shared.core.object')
local vec2 = require('shared.core.vec2')

local client = {}

 test_obj = nil

function client.load(args)
	test_obj = Object:new(vec2(100, 100), vec2(10, 10))
	test_obj:ApplyAngularImpulse(500)
end

function client.update(dt)
	if love.keyboard.isDown(' ') then
		test_obj:ApplyForce(vec2(100, 0))
		test_obj:ApplyTorque(50)
	end
	test_obj:Update(dt)
end

function client.draw()
	love.graphics.push()
	
	love.graphics.translate(test_obj.state.pos.x, test_obj.state.pos.y)
	love.graphics.rotate(test_obj.rot_state.x)
	love.graphics.circle('fill', 0, 0, 8, 4)
	love.graphics.pop()
end

function client.quit()

end

function client.run()
	love.math.setRandomSeed(os.time())
	for i = 1, 3 do love.math.random() end

	love.event.pump()

	client.load(arg)
	love.timer.step()

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

		love.timer.sleep(0.001)
	end
end

return client