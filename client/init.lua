local Object = require 'shared.core.object'
local vec2 = require 'shared.core.vec2'
local Serializer = require 'shared.core.serializer'

local Ship = require 'shared.game.ship'

local client = {}

 test_obj = nil

function client.load(args)
	test_obj = Object:new(vec2(100, 100), vec2(0, 0), 0, 0)
	test_obj.mass = 1.25
	
	local objects = {}
	for i = 1, 10 do
		objects[i] = Object:new(vec2(i, i), vec2(i, i), i, i)
		objects[i].mass = 2.5
		print(objects[i].state.pos)
	end

	local ser_test = Serializer:new()
	ser_test:Put(test_obj)

	local ship = Ship:new()
	print(ship.state)
	ser_test:Put(ship)

	ser_test:PutString("poop")
	local array = ser_test:PutArray(Object, objects)

	local buf = ser_test:Write(true, 'lz4')


	local read_test = Serializer:new()
	read_test:Read(buf)

	local obj = read_test:Get(Object, 1)
	print(obj.state.pos)


	local objects_d = read_test:GetArray(Object, array)
	for i = 1, 10 do
		print(objects_d[i].state.pos)
	end
end

function client.update(dt)
	if love.keyboard.isDown('a') then
		test_obj:ApplyTorque(-500)
	end
	if love.keyboard.isDown('d') then
		test_obj:ApplyTorque(500)
	end
	if love.keyboard.isDown('w') then
		test_obj:ApplyForce(vec2(math.cos(test_obj.rot_state.x) * 5000, math.sin(test_obj.rot_state.x) * 5000))
	end
	test_obj:Update(dt)
end

function client.draw()
	love.graphics.push()
	
	love.graphics.translate(test_obj.state.pos.x, test_obj.state.pos.y)
	love.graphics.rotate(test_obj.rot_state.x)
	love.graphics.rectangle('fill', -10, -5, 20, 10)
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