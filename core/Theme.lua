
 -- @print including(core.Theme)

@class Theme {
	application = nil;
	rules = {};
	lifetime = {};
	ID = 0;
}

function Theme:Theme( app )
	self.application = app
	self.rules = {}
	self.lifetime = {}
end

function Theme:apply()
	-- TODO: add all rules
end

function Theme:unapply()
	-- TODO: kill self.lifetime
end

function Theme:add_rule( selector, styles )
	local ID = self.ID
	local elems, qID = self.application:query_tracked( selector )

	styles.ID = ID -- hacky but oh well :/

	local function f( mode, child )
		if mode == "child-removed" then
			for i = 1, #child.active_styles do
				if child.active_styles[i] == styles then
					table.remove( child.active_styles, i )
					return child:update_styles( i )
				end
			end
		elseif mode == "child-added" then
			local inserted = nil

			for i = 1, #child.active_styles do
				if child.active_styles[i].ID > ID then
					table.insert( child.active_styles, i, styles )
					inserted = i
					break
				end
			end

			if not inserted then
				child.active_styles[#child.active_styles + 1] = styles
			end

			child:update_styles( inserted or #child.active_styles )
		end
	end

	-- the styles table reference is important, don't ever change thingy.styles
	self.rules[#self.rules + 1] = { ID = ID, selector = selector, styles = styles }
	self.ID = self.ID + 1

	self.application.query_tracker:subscribe( qID, self.lifetime, f )

	for i = 1, #elems do
		f( "child-added", elems[i] )
	end

	return ID
end

function Theme:remove_rule( ID )
	for i = 1, #self.rules do
		if self.rules[i].ID == ID then
			return table.remove( self.rules, i )
		end
	end
end

-- change_selector()
-- change_styles()
