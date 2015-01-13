function getAccountID( player )
	return ( isElement( player ) and getElementData( player, "database:id" ) ) and tonumber( getElementData( player, "database:id" ) ) or false
end

function getAccountName( player )
	return isElement( player ) and getElementData( player, "account:username" ) or false
end

function getCharacterID( player )
	return ( isElement( player ) and getElementData( player, "character:id" ) ) and tonumber( getElementData( player, "character:id" ) ) or false
end

function getPlayerByAccountID( accountID )
	for _, player in ipairs( getElementsByType( "player" ) ) do
		if ( getAccountID( player ) == accountID ) then
			return player
		end
	end
	
	return false
end

function getPlayerByCharacterID( characterID )
	for _, player in ipairs( getElementsByType( "player" ) ) do
		if ( getCharacterID( player ) == characterID ) then
			return player
		end
	end
	
	return false
end

function getPlayerByID( id )
	for _, player in ipairs( getElementsByType( "player" ) ) do
		if ( getPlayerID( player ) == id ) then
			return player
		end
	end
	
	return false
end

function getPlayerFromPartialName( string, player )
	if ( not string ) then
		return false
	end
	
	if ( not tonumber( string ) ) and ( string == "*" ) and ( getElementType( player ) == "player" ) then
		return isPlayerPlaying( player ) and player or false
	else
		if ( tonumber( string ) ) and ( tonumber( string ) > 0 ) then
			return getPlayerByID( tonumber( string ), player )
		end
		
		local matches = { }
		
		for _, player in ipairs( getElementsByType( "player" ) ) do
			if ( getPlayerName( player ) == string ) and ( isPlayerPlaying( player ) ) then
				return player
			end
			
			local playerName = getPlayerName( player ):gsub( "#%x%x%x%x%x%x", "" )
			playerName = playerName:lower( )
			
			if ( playerName:find( string:lower( ), 0 ) ) and ( isPlayerPlaying( player ) ) then
				table.insert( matches, player )
			end
		end
		
		if ( #matches == 1 ) then
			return matches[ 1 ]
		end
		
		return false, #matches
	end
end

function getPlayerID( player )
	return ( isElement( player ) and getElementData( player, "player:id" ) ) and tonumber( getElementData( player, "player:id" ) ) or false
end

local _getPlayerName = getPlayerName
function getPlayerName( player, format )
	if ( isElement( player ) ) then
		local name = _getPlayerName( player ):gsub( "_", " " )
		
		return format and formatString( name ) or name
	end

	return false
end

function isPlayerPlaying( player )
	return isElement( player ) and getElementData( player, "player:playing" ) or false
end