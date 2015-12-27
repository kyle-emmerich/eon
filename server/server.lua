require 'enet'
local config = require 'shared.config'
local Client = require 'server.client'

local server = {}

function server.load(args)
	server.host = enet.host_create("localhost:" .. config.port)
	server.clients = {}
	server.players = {}
end

function server:OnConnect(ev)
	server.clients[ev.peer:connect_id()] = Client:new(ev.peer)
end

function server:OnDisconnect(ev)

end

function server:OnReceive(ev)
	--decode data
	if #ev.data < 3 then
		return
	end
	local format = string.sub(ev.data, 1, 1)
	local type_ = string.sub(ev.data, 2, 2)
	local encoded = string.sub(ev.data, 3)

	if format == 0 then
		return
	elseif format == 1 then
		--binary data, uncompressed

	elseif format == 2 then
		--binary data, compressed

	elseif format == 3 then
		--binary data, 
	end
	server.clients[ev.peer:connect_id()]:OnReceive(server, ev)
end

function server.update(dt)
	local ev = server.host:service()
	while ev do
		if ev.type == "receive" then
			server:OnReceive(ev)
		elseif ev.type == "connect" then
			server:OnConnect(ev)
		elseif ev.type == "disconnect" then
			server:OnDisconnect(ev)
		end
		ev = server.host:service()
	end
end

return server