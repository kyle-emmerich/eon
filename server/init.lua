local server = {}

function client.load(args)

end

function client.update(dt)

end

function client.draw()

end

function client.quit()

end

function server.run()
	love.math.setRandomSeed(os.time())
	for i = 1, 3 do love.math.random() end

	love.event.pump()

	server.load(arg)
	love.timer.step()

	local dt = 0
	while true do
		love.event.pump()
		for e, a, b, c, d in love.event.poll() do
			if e == "quit" then
				if not server.quit() then
					return
				end
			else
				if server[e] then
					server[e](a,b,c,d)
				end
			end
		end
		love.timer.step()
		dt = love.timer.getDelta()

		server.update(dt)

		love.timer.sleep(0.001)
	end
end

return server