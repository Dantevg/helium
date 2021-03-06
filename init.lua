--[[--
	
	Helium (He) framework
	
	@module helium
	@author RedPolygon
	
]]--

local Box = require "helium.Box"

local He = {}
He._VERSION = "0.5"

He.__index = He

--- @type Helium

--- Create a new Helium context.
-- @tparam number w the width of the root element
-- @tparam number h the height of the root element
-- @treturn Helium the new Helium root element
function He.new(w, h)
	local self = Box(0, 0, w, h)
	self.style = setmetatable({}, {__index = He.style})
	return setmetatable(self, He)
end

--- Get a style value for a node.
-- @tparam string style the style to get
-- @tparam Node node the node for which to get the style
-- @return the style value, or nil
function He:Style(style, node)
	for _, tag in ipairs(node.tags or {"*"}) do
		if self.style[tag] and self.style[tag][style] then
			if type(self.style[tag][style]) == "function" then
				local value = self.style[tag][style](node)
				if value then return value end
			else
				return self.style[tag][style]
			end
		end
	end
end

function He:drawself(canvas) end -- Do not draw root node

function He:__tostring()
	return string.format("Helium Root %dx%d", self.w, self.h)
end

-- Default style
He.style = setmetatable({}, {
	__index = function(_, k)
		He.style[k] = {} -- Create new style table
		return He.style[k]
	end
})
He.style["*"] = {
	colour = {255, 255, 255}
}

return setmetatable(He, {
	__call = function(_, ...) return He.new(...) end,
	__index = function(_, k)
		-- Behave like __index = Box
		if Box[k] then return Box[k] end
		
		-- Require modules when needed
		local success, module = pcall(require, "helium."..k)
		if success then
			He[k] = module
			return module
		end
	end,
})
