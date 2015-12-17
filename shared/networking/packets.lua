local cdata = require 'shared.cdata'
local packets = {}

function add(name, fields, map)
	local struct = string.format("typedef struct { uint8_t type; %s } %s;", fields, name)
	cdata:new_struct(name, struct)

	if map then
		map.name = name
		table.insert(packets, map)
		packets[name] = #packets
	end
end

add("packet_type", "")

add(
	"niggers", 
	[[

		uint16_t id;

	]], 
	{
		"id"
	}
)
