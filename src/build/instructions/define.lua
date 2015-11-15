
local module = {}

function module:define( data )
	self:write ""
	local w = data:match "^[%w_]+"
	if not w then
		return error( "Expected word to define in '@define', got " .. ("%q"):format( data ) )
	end
	local r = data:match "^[%w_]+%s*(.-)$"
	if #r > 0 then
		self.macros[w] = r
		self.env[w] = r ~= "false"
	else
		self.macros[w] = "true"
		self.env[w] = true
	end
end

function module:undef( data )
	self:write ""
	self.env[data] = nil
	self.macros[data] = nil
end

function module:defineifndef( data )
	self:write ""
	local w = data:match "^[%w_]+"
	if not w then
		return error( "Expected word to define in '@define', got " .. ("%q"):format( data ) )
	end
	if self.env[w] == nil then
		local r = data:match "^[%w_]+%s*(.-)$"
		if #r > 0 then
			self.macros[w] = r
			self.env[w] = r ~= "false"
		else
			self.macros[w] = "true"
			self.env[w] = true
		end
	end
end

return module
