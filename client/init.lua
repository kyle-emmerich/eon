local UI = require 'client.ui'
UI.Frame = require 'client.ui.frame'
UI.Button = require 'client.ui.button'
UI.Stack = require 'client.ui.stack'
UI.TextInput = require 'client.ui.textinput'
local UDim = require 'client.ui.udim'

local Object = require 'shared.core.object'
local vec2 = require 'shared.core.vec2'
local uuid = require 'shared.core.uuid'
local Serializer = require 'shared.core.serializer'

local RenderSystem = require 'shared.core.rendersystem'

local PointLight = require 'shared.core.pointlight'

local System = require 'shared.game.system'

local Ship = require 'shared.game.ship'
local ShipHull = require 'shared.game.shiphull'
local ShipComponent = require 'shared.game.shipcomponent'

local client = require 'client.client'
client.rendersystem = false

local ship = nil

function client.load(args)
	local ip = args[3] or "127.0.0.1"
	client.connect(ip)
	ShipHull.static.init()
	ShipComponent.static.init()

	client.rendersystem = RenderSystem:new()
	client.rendersystem.current_system = System:new()

	for i = 1, 10 do
		local light = PointLight:new()
		light.color = {255, 255, 255, 255}
		local object = Object:new(vec2(100 * i, 100 * i), vec2(30, 0), 0, 0)
		object:SetRenderable(light)
		client.rendersystem.current_system:AddObject(object)
	end

	
	ship = Ship:new(ShipHull.static.hulls[1])
	ship.state.pos = vec2(100, 100)
	ship:SetHull(ShipHull.static.hulls[1])
	ship.custom_color.r = 133
	ship.custom_color.g = 211
	ship.custom_color.b = 237


	local engine = ShipComponent.static.components[ShipComponent.static.Types.Engine]:new()
	engine.subtype_uid = 'expengx1'
	engine:LoadFromSubtypeInfo()
	local engine2 = ShipComponent.static.components[ShipComponent.static.Types.Engine]:new()
	engine2.subtype_uid = 'expengx1'
	engine2:LoadFromSubtypeInfo()
	local sidefarts = ShipComponent.static.components[ShipComponent.static.Types.AttitudeControl]:new()
	sidefarts.subtype_uid = 'sidefart'
	sidefarts:LoadFromSubtypeInfo()
	ship:AddComponent(engine)
	ship:AddComponent(engine2)
	ship:AddComponent(sidefarts)

	client.rendersystem.current_system:AddObject(ship)

	UI:Load(require 'client.ui.control')

	local frame = UI.Frame:new()
	frame.udim = UDim:new(0, 400, 0, 400, 0, 400, 0, 300)
	frame:SetParent(UI.root)
	frame:SetText("Bite my ass")

	local stack = UI.Stack:new()
	stack:SetParent(frame)

	for i = 1, 2 do
		local button = UI.Button:new()
		button:SetHeight(50)
		button:SetText("Smell me")
		button:SetMargins(5, 5, 5, 0)
		button:SetParent(stack)
	end

	local textinput = UI.TextInput:new()
	textinput:SetHeight(40)
	textinput:SetMargins(5, 5, 5, 0)
	textinput:SetParent(stack)

	local password = UI.TextInput:new()
	password:SetHeight(40)
	password:SetMargins(5, 5, 5, 0)
	password:SetParent(stack)
	password.mask = true

	stack:Invalidate()
	frame:Layout()

	local exo2 = require 'shared.asset.font.exo2'
	love.graphics.setFont(exo2:Get('regular', 'regular', 18))

	love.keyboard.setKeyRepeat(true)
end

local input = {}
function client.update(dt)
	client.network_update(dt)

	input.forward = false
	input.left = false
	input.right = false
	if UI.focused == false then
		if love.keyboard.isDown('a') then
			input.left = true
		end
		if love.keyboard.isDown('d') then
			input.right = true
		end
		if love.keyboard.isDown('w') then
			input.forward = true
		end
	end
	ship:ApplyInput(input)
	client.rendersystem.current_system:Update(dt)

	UI:Update(dt)
end

function client.draw()	
	love.graphics.setColor(255, 255, 255, 255)
	client.rendersystem:Render()

	UI:Render()
end

function client.quit()

end

function client.resize()
	client.rendersystem:Resize()
end

function client.mousepressed(x, y, idx)
	UI:MouseDown(x, y, idx)
end

function client.mousereleased(x, y, idx)
	UI:MouseUp(x, y, idx)
end

function client.textinput(text)
	UI:InputText(text)
end

function client.keypressed(key, scancode, is_repeat)
	UI:KeyDown(key, scancode, is_repeat)
end
function client.keyreleased(key, scancode, is_repeat)
	UI:KeyUp(key, scancode, is_repeat)
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