local UI = {}
UI.elements = {}
UI.root = false
UI.hovered = false
UI.focused = false
UI.dragging = false
UI.drag_x = 0
UI.drag_y = 0
UI.drag_px = 0
UI.drag_py = 0

UI.Control = false

--TODO: Wrap up theme stuff, move it out
--TODO: load all elements into this table rather than making client code do it

UI.Colors = {
	Normal = { 64, 64, 64, 255 },
	Hovered = { 128, 128, 128, 255 },

	FrameTitlebarColor = { 48, 48, 48, 255 },
	FrameTitlebarTextColor = { 255, 255, 255, 255 },

	ButtonColor = {50, 50, 50, 255 },
	ButtonHoverColor = { 60, 60, 60, 255 },
	ButtonActiveColor = { 35, 35, 35, 255 },
	ButtonTextColor = { 255, 255, 255, 255 },

	InputColor = { 50, 50, 50, 255 },
	InputHoverColor = { 55, 55, 55, 255 },
	InputActiveColor = { 50, 50, 50, 255 },
	InputTextColor = { 255, 255, 255, 255 }
}
local exo2 = require 'shared.asset.font.exo2'
UI.Fonts = {
	FrameTitlebarText = exo2:Get('light', 'regular', 16),

	ButtonText = exo2:Get('light', 'regular', 14),

	NormalText = exo2:Get('light', 'regular', 14)
}

function UI:Load(control)
	UI.Control = control
	UI.root = control:new()
	UI:Resize()
end

function UI:Update(dt)
	local last_hovered = UI.hovered
	UI.hovered = false
	UI.root:Update(dt)

	if UI.dragging then
		local dx = love.mouse.getX() - UI.drag_x
		local dy = love.mouse.getY() - UI.drag_y
		UI.dragging:DragTo(UI.drag_px + dx, UI.drag_py + dy, dx, dy)
	else
		if not UI.hovered and last_hovered then
			last_hovered:OnMouseLeave()
		end
		if UI.hovered and UI.hovered ~= last_hovered then
			if last_hovered then
				last_hovered:OnMouseLeave()
			end
			UI.hovered:OnMouseHover()
		end
	end
end

function UI:Render()
	UI.root:Render()
end

function UI:Resize()
	UI.root.udim.ow = love.graphics.getWidth()
	UI.root.udim.oh = love.graphics.getHeight()
	UI.root.dirty = true
end

function UI:MouseDown(x, y, idx)
	if UI.hovered and UI.hovered.draggable then
		UI.dragging = UI.hovered
		local no_cancel = UI.dragging:OnDragStart(x, y)
		if not no_cancel then
			UI.dragging = false
		else
			UI.drag_x = love.mouse.getX()
			UI.drag_y = love.mouse.getY()
			UI.drag_px = UI.dragging.udim.ox
			UI.drag_py = UI.dragging.udim.oy
		end
	end

	UI.root:OnMouseDown(x, y, idx)

	if UI.hovered and UI.hovered.can_focus then
		if UI.focused then
			UI.focused:OnFocus(false)
		end
		UI.focused = UI.hovered
		UI.focused:OnFocus(true)
	end

	if not UI.hovered or not UI.hovered.can_focus then
		if UI.focused then
			UI.focused:OnFocus(false)
		end
		UI.focused = false
	end
end
function UI:MouseUp(x, y, idx)
	if UI.dragging then
		UI.dragging:OnDragStop()
		UI.dragging = false
		UI.drag_x = 0
		UI.drag_y = 0
		UI.drag_px = 0
		UI.drag_py = 0
	end

	UI.root:OnMouseUp(x, y, idx)
end

function UI:InputText(text)
	if UI.focused then
		UI.focused:OnTextInput(text)
	end
end

function UI:KeyDown(key, scancode, is_repeat)
	if UI.focused then
		UI.focused:OnKeyDown(key, scancode, is_repeat)
	end
end
function UI:KeyUp(key, scancode, is_repeat)
	if UI.focused then
		UI.focused:OnKeyUp(key, scancode, is_repeat)
	end
end

return UI