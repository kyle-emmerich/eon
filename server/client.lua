local class = require 'shared.class'
local sha256 = require 'shared.core.sha256'

local Serializer = require 'shared.core.serializer'
local ffi = require 'ffi'

ffi.cdef [[

typedef struct {
	ID userid;
	string username;

	uint32_t password[8];
} Client_data;

]]

local Client = class('Client')
Client.data = ffi.typeof('Client_data')
function Client:initialize(peer)
	self.peer = peer

	self.userid = false
	self.username = false
end

function Client:OnAuthenticate(server, username, password)
	
	local path = "data/users/" .. username:lower()

	if love.filesystem.exists(path) then
		--load file, check it out
		local data = love.filesystem.newFileData(path)
		local serializer = Serializer:new()

		serializer:Read(data)
		local client_data = serializer:Get(Client, 0, self)

		local password_hash = sha256(password)
		for i = 0, 7 do 
			if password_hash[i] ~= client_data.password[i] then
				return false, "The credentials supplied were incorrect."
			end
		end
	else
		return false, "That username does not exist."
	end

	server.players[self.userid] = self
	return true, "Authenticated successfully!"
end

function Client:OnReceive(server, ev)
	
end

function Client:Serialize(serializer)
	local data = Client.data()

	data.userid = self.userid
	data.username = serializer:PutString(self.username)

end

function Client:Deserialize(serializer, data)
	self.userid = data.userid
	self.username = data.username
end

return Client