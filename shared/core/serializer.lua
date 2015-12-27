local class = require 'shared.class'
local ffi = require 'ffi'

ffi.cdef [[

typedef struct {
	uint32_t offset;
	uint32_t length;
} array;

typedef uint32_t string;
typedef uint16_t ID;

typedef struct {
	uint16_t num_sections;
	uint16_t num_strings;
} DataHeader;

typedef struct {
	char classname[128];
	uint32_t offset;
	uint32_t length;
} DataSection;

]]


local DataHeader = ffi.typeof('DataHeader')
local DataSection = ffi.typeof('DataSection')
local array = ffi.typeof('array')

local Serializer = class('Serializer')
function Serializer:initialize()
	self.data = false

	self.header = false
	self.strings = {}

	self.sections = {}
	self.section_map = {}
	self.section_ptrs = {}
	self.section_types = {}
	self.section_unpacked = {}
end

function Serializer:Read(buffer)
	if type(buffer) ~= 'string' then
		buffer = love.math.decompress(buffer)
	end

	--Let's look at the header
	buffer = ffi.cast('uint8_t*', buffer)
	self.data = buffer
	self.header = ffi.cast('DataHeader*', buffer)[0]
	local ptr = buffer + ffi.sizeof('DataHeader')

	for i = 1, self.header.num_strings do
		self.strings[i] = ffi.string(ptr)
		ptr = ptr + self.strings[i]:len() + 1
	end

	for i = 1, self.header.num_sections do
		local section = ffi.cast('DataSection*', ptr)
		ptr = ptr + ffi.sizeof('DataSection')

		self.sections[i] = section
		local classname = ffi.string(self.sections[i].classname)
		self.section_ptrs[i] = ffi.cast(classname .. '_data*', buffer + self.sections[i].offset)
		self.section_map[classname] = i
	end
end

function Serializer:Write(compress, format)
	--first step: evaluate the size of our buffer
	local size = ffi.sizeof('DataHeader')
	--add string lengths
	for i = 1, #self.strings do
		size = size + self.strings[i]:len() + 1
	end
	--now each section
	for i = 1, #self.sections do
		size = size + ffi.sizeof('DataSection')
		size = size + (ffi.sizeof(self.section_types[i].name .. '_data') * #self.section_unpacked[i])
	end

	--and create the buffer, write the header
	local buffer = ffi.new('uint8_t[?]', size)
	local header = ffi.cast('DataHeader*', buffer)
	header.num_sections = #self.sections
	header.num_strings = #self.strings
	local ptr = buffer + ffi.sizeof('DataHeader')

	--write strings
	for i = 1, header.num_strings do
		local str = self.strings[i]
		ffi.copy(ptr, str, #str + 1)
		ptr = ptr + #str + 1
	end

	--write sections
	local sections_offset = ffi.cast('DataSection*', ptr)
	for i = 1, #self.sections do
		self.sections[i].length = #self.section_unpacked[i]
		ffi.copy(ptr, self.sections[i], ffi.sizeof('DataSection'))
		self.sections[i] = ffi.cast('DataSection*', ptr)
		ptr = ptr + ffi.sizeof('DataSection')
	end

	for i = 1, #self.sections do
		--We need to pack up our data now.
		self.sections[i].offset = ptr - buffer
		local packed = ffi.cast(self.section_types[i].name .. '_data*', ptr)
		local type_size = ffi.sizeof(self.section_types[i].name .. '_data')
		for j = 1, #self.section_unpacked[i] do
			packed[j - 1] = self.section_unpacked[i][j]
		end
		ptr = ptr + (type_size * #self.section_unpacked[i])
	end

	local final_buf = ffi.string(buffer, size)
	if compress then
		final_buf = love.math.compress(final_buf, format or 'gzip')
	end
	return final_buf
end

function Serializer:GetArray(class_, array)
	local offset = array.offset
	local length = array.length
	if length == 0 then
		return {}
	end
	local section = self.sections[self.section_map[class_.name]]
	local data = self.section_ptrs[self.section_map[class_.name]]
	

	if offset + length > section.length then
		error("Tried to read too many " .. class_.name .. " objects from Serializer")
	end

	local ptr = ffi.cast(class_.name .. '_data*', data)
	local type_size = ffi.sizeof(class_.name .. '_data')
	local objects = {}
	local j = 1
	for i = offset, offset + length - 1 do
		objects[j] = class_:new()
		objects[j]:Deserialize(self, ptr[i])
		j = j + 1
	end
	return objects
end

function Serializer:Get(class_, index, object)
	index = index or 0
	local section = self.sections[self.section_map[class_.name]]
	local data = self.section_ptrs[self.section_map[class_.name]]
	local ptr = ffi.cast(class_.name .. '_data*', data)

	if index <= 0 then
		error("Index out of bounds for Serializer:Get(" .. class_.name .. ", " .. index .. "), was too low")
	end
	if index > section.length then
		error("Index out of bounds for Serializer:Get(" .. class_.name .. ", " .. index .. "), only have " .. section.length)
	end

	object = object or class_:new()
	object:Deserialize(self, ptr[index - 1])
	return object
end

function Serializer:GetString(index)
	return self.strings[index + 1]
end

function Serializer:_newsection(class_)
	local section = DataSection()
	section.classname = class_.name

	table.insert(self.sections, section)
	self.section_map[class_.name] = #self.sections
	self.section_ptrs[#self.sections] = false
	self.section_unpacked[#self.sections] = {}
	self.section_types[#self.sections] = class_
end

function Serializer:Put(object)
	local classname = object.class.name
	if not self.section_map[classname] then
		self:_newsection(object.class)
	end
	local section_idx = self.section_map[classname]
	local section = self.sections[section_idx]
	table.insert(self.section_unpacked[section_idx], object:Serialize(self))
	return #self.section_unpacked[section_idx]
end

function Serializer:PutArray(class_, objects)
	if #objects == 0 then
		return array()
	end
	local classname = class_.name
	if not self.section_map[classname] then
		self:_newsection(class_)
	end
	local section_idx = self.section_map[classname]

	local offset = #self.section_unpacked[section_idx]
	for i = 1, #objects do
		table.insert(self.section_unpacked[section_idx], objects[i]:Serialize(self))
	end
	local arr = array()
	arr.offset = offset
	arr.length = #objects
	return arr
end

function Serializer:PutString(str)
	table.insert(self.strings, str)
	return #self.strings
end

return Serializer