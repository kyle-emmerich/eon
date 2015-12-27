local Utility = {}

function Utility.PointInsideRect(x, y, w, h, px, py)
	if px >= x and px <= x + w and py >= y and py <= y + h then
		return true
	end
	return false
end

function Utility.PointInsideCircle(x, y, r, px, py)
	local dx, dy = px - x, py - y
	local ds = dx ^ 2 + dy ^ 2
	if ds <= r ^ 2 then
		return true
	end
	return false
end

return Utility