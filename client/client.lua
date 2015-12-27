require "enet"
local config = require 'shared.config'

local client = {}
client.host = enet.host_create()
client.connection = false
client.connecting = false
client.connected = false

function client.connect(ip)
	local str = ip .. ":" .. config.port
	client.connection = client.host:connect(str)
	client.connecting = true

	print("Connecting to " .. str)
end

function client:OnReceive(ev)

end

function client:OnConnected(ev)

end

function client:OnDisconnected(ev)

end

function client.network_update(dt)
	local ev = client.host:service()
	while ev do
		if ev.type == "receive" then
			client:OnReceive(ev)
		elseif ev.type == "connect" then
			client.connected = true
			client.connecting = false
			client:OnConnected(ev)
		elseif ev.type == "disconnect" then
			client.connected = false
			client:OnDisconnected(ev)
		end
		ev = client.host:service()
	end
end

return client