local class = require 'shared.class'
local UI = require 'client.ui'
local Control = require 'client.ui.control'
local utf8 = require 'utf8'

local TextInput = class('TextInput', Control)
function TextInput:initialize()
	Control.initialize(self)

	self.can_focus = true

	self.font = UI.Fonts.NormalText
	self.contents = ""
	self.text = ""
	self.text_color = UI.Colors.InputTextColor

	self.cursor = 0
	self.cursor_blink = 0
	self.cursor_blink_interval = 0.5
	self.cursor_insert = false

	self.mask = false
	self.mask_char = '•'

	self.color = UI.Colors.InputColor 
	self.hover_color = UI.Colors.InputHoverColor
	self.active_color = UI.Colors.InputActiveColor
end

function TextInput:OnMouseDown(x, y, idx)
	x = x - self.x
	local len = utf8.len(self.text)
	if len > 0 then
		local last_char = utf8.offset(self.text, -1)
		local total = self.font:getWidth(self.text) + self.font:getWidth(self.text:sub(last_char)) / 2
		if x >= total then
			self.cursor = len
			print('past total')
			return
		end--todo: handle clicking last char

	end
	for i = 1, len do
		local pos = utf8.offset(self.text, i) or 1
		local next_char_byte = utf8.offset(self.text, i + 1) or 1
		if not pos then
			self.cursor = 0
			return
		end
		if not next_char_byte then
			self.cursor = len
			return
		end
		local next_char = self.text:sub(pos, next_char_byte - 1)
		local subtext = self.text:sub(1, pos - 1)
		local width = self.font:getWidth(subtext)
		local width_next = self.font:getWidth(next_char)

		if width + (width_next / 2) < x then
			self.cursor = i - 1
		else
			return
		end
	end
end

function TextInput:_update_text()
	if self.mask then
		self.contents = ""
		local len = utf8.len(self.text)
		for i = 1, len do
			self.contents = self.contents .. self.mask_char
		end
	else
		self.contents = self.text
	end
end

function TextInput:OnTextInput(text)
	if self.cursor_insert then
		local insert_pos = utf8.offset(self.text, self.cursor)
		local byte_after = utf8.offset(self.text, self.cursor + 2)
		local old = self.text
		if insert_pos and byte_after then
			self.text = old:sub(1, insert_pos) .. text .. old:sub(byte_after)
		end
	else
		local insert_pos = utf8.offset(self.text, self.cursor)
		local byte_after = utf8.offset(self.text, self.cursor + 1)
		local old = self.text
		self.text = old:sub(1, insert_pos) .. text .. old:sub(byte_after)
	end
	self.cursor = self.cursor + 1

	self.cursor_blink = love.timer.getTime()

	self:_update_text()
end

function TextInput:OnFocus(focused)
	Control.OnFocus(self, focused)
	print(focused)
	self.focused = focused
	if focused then
		self.cursor_blink = love.timer.getTime()
	end
end

function TextInput:OnKeyDown(key)
	if key == 'backspace' and self.cursor > 0 then
		local byte = utf8.offset(self.text, self.cursor)
		if byte then
			local byte_after = utf8.offset(self.text, self.cursor + 1)
			local after = ""
			if byte_after then
				after = string.sub(self.text, byte_after)
			end
			self.text = string.sub(self.text, 1, byte - 1) .. after
			self.cursor = self.cursor - 1
		end
	end
	if key == 'delete' and self.cursor <= utf8.len(self.text) then
		local byte = utf8.offset(self.text, self.cursor + 1)
		if byte then
			local byte_after = utf8.offset(self.text, self.cursor + 2)
			local after = ""
			if byte_after then
				after = string.sub(self.text, byte_after)
			end
			self.text = string.sub(self.text, 1, byte - 1) .. after
		end
	end
	if key == 'left' then
		self.cursor = math.max(0, self.cursor - 1)
		self.cursor_blink = love.timer.getTime()
	end
	if key == 'right' then
		self.cursor = math.min(utf8.len(self.text), self.cursor + 1)
		self.cursor_blink = love.timer.getTime()
	end
	if key == 'insert' then
		--self.cursor_insert = not self.cursor_insert
		--TODO: fix insert
	end
	
	self:_update_text()
end

function TextInput:_render()
	Control._render(self)

	local offset = self.h / 2 - self.font:getHeight() / 2
	love.graphics.setColor(self.text_color)

	love.graphics.print(self.contents, self.x + offset, self.y + offset)

	local t = (love.timer.getTime() - self.cursor_blink) / self.cursor_blink_interval
	if self.focused then
		local cursor_x1 = self.x + offset
		
		if self.cursor > 0 then
			local byte = utf8.offset(self.contents, self.cursor + 1)
			local str = self.contents:sub(1, byte - 1)
			cursor_x1 = cursor_x1 + self.font:getWidth(str)
		end
		local cursor_x2 = 0.5
		if self.cursor_insert then
			local byte = utf8.offset(self.contents, self.cursor - 1)
			local byte_next = utf8.offset(self.contents, self.cursor)
			if byte and byte_next then
				cursor_x2 = self.font:getWidth(self.contents:sub(byte, byte_next - 1))
			else
				cursor_x2 = self.font:getWidth(' ')
			end
		end

		love.graphics.setColor(255, 255, 255, 255 * (1-(t % 2)))

		cursor_x1 = math.floor(cursor_x1) + 0.5
		cursor_x2 = math.floor(cursor_x2) + 0.5
		love.graphics.setLineStyle('rough')	
		love.graphics.rectangle('fill', cursor_x1, self.y + offset - 1, cursor_x2, self.font:getHeight() + 2)
	end
end

return TextInput