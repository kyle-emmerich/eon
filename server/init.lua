love.errhand = function(msg)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
	while true do
		love.event.pump()
	end
end

local Server = require 'server.server'

function Server.draw()

end

function Server.quit()

end

function Server.run()
	love.math.setRandomSeed(os.time())
	for i = 1, 3 do love.math.random() end

	love.event.pump()

	Server.load(arg)
	love.timer.step()

	local dt = 0
	while true do
		love.event.pump()
		for e, a, b, c, d in love.event.poll() do
			if e == "quit" then
				if not Server.quit() then
					return
				end
			else
				if Server[e] then
					Server[e](a,b,c,d)
				end
			end
		end
		love.timer.step()
		dt = love.timer.getDelta()

		Server.update(dt)

		love.timer.sleep(0.001)
	end
end



return Server