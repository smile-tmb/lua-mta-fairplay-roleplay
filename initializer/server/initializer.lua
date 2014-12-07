local resources = { "security", "database", "common", "messages", "accounts", "admin", "realism", "items", "inventory", "chat", "vehicles", "factions", "scoreboard", "superman" }

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		local tick = getTickCount( )
		local builder = getResourceFromName( "builder" )
		
		if ( getResourceState( builder ) ~= "running" ) then
			startResource( builder )
		end
		
		for _, resourceName in ipairs( resources ) do
			local resource = getResourceFromName( resourceName )
			
			if ( resource ) then
				exports.builder:load_resource( resourceName )
			end
		end
		
		outputDebugString( "Took " .. math.floor( getTickCount( ) - tick ) .. " ms (average is " .. math.floor( ( getTickCount( ) - tick ) / 1000 * 100 ) / 100 .. " seconds) to load all resources." )
	end
)