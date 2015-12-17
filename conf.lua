function conf_client(t)
	t.console = true
	t.window.width = 1280
	t.window.height = 720
	t.window.title = "Eon"
	t.window.vsync = true
	t.window.fsaa = 4
	t.window.display = 1
	t.window.srgb = false
	t.window.resizable = true

	t.modules.audio = true
	t.modules.event = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = false
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = false
	t.modules.sound = true
	t.modules.system = true
	t.modules.timer = true
	t.modules.window = true
	t.modules.thread = true
end

function conf_server(t)
	t.console = true
	t.window = false

	t.modules.audio = false
	t.modules.event = true
	t.modules.graphics = false
	t.modules.image = true
	t.modules.joystick = false
	t.modules.keyboard = false
	t.modules.math = true
	t.modules.mouse = false
	t.modules.physics = false
	t.modules.sound = false
	t.modules.system = true
	t.modules.timer = true
	t.modules.window = false
	t.modules.thread = true
end

function love.conf(t)
	t.console = true
	if arg[2] == 'client' then
		conf_client(t)
	elseif arg[2] == 'server' then
		conf_server(t)
	else
		error("Invalid start argument, must be client or server")
	end

	run_mode = arg[2]
end