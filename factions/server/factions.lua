function getFactions( )
	local factions = { }
	
	for _, team in ipairs( getElementsByType( "team" ) ) do
		if ( getElementData( team, "faction:id" ) ) then
			table.insert( factions, team )
		end
	end
	
	return factions
end

function getFactionByID( id )
	for _, faction in ipairs( getFactions( ) ) do
		if ( tonumber( getElementData( faction, "faction:id" ) ) == id ) then
			return faction
		end
	end
	
	return false
end

function getFactionByName( name )
	for _, faction in ipairs( getFactions( ) ) do
		if ( tonumber( getElementData( faction, "faction:name" ) ) == name ) then
			return faction
		end
	end
	
	return false
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		local civilians = createTeam( "Civilian", 255, 255, 255 )
	end
)