local ffi = require 'ffi'
ffi.cdef [[

typedef struct {
	uint8_t r;
	uint8_t g;
	uint8_t b;
	uint8_t a;
} color;

]]

local color = ffi.typeof('color')

return color