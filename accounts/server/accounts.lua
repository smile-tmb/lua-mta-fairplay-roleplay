local _get = get

function get( id )
	return exports.database:query_single( "SELECT * FROM `accounts` WHERE `id` = ?", id )
end

function new( username, password )
	return exports.database:insert_id( "INSERT INTO `accounts` (`username`, `password`) VALUES (?, ?)", username, exports.security:hashString( password ) )
end

function login( player, username, password )
	if ( getElementType( player ) ~= "player" ) then
		return false
	end
	
	local account = exports.database:query_single( "SELECT * FROM `accounts` WHERE `username` = ? AND `password` = ?", username, exports.security:hashString( password ) )
	
	if ( account ) then
		exports.security:modifyElementData( player, "database:id", account.id, false )
		exports.security:modifyElementData( player, "account:username", account.username, true )
		exports.security:modifyElementData( player, "account:rank", account.rank, true )
		exports.security:modifyElementData( player, "player:name", getPlayerName( player ), true )
		
		triggerClientEvent( player, "accounts:onLogin", player )
		
		return true
	end
	
	return false
end

function register( username, password )
	local query = exports.database:query_single( "SELECT NULL FROM `accounts` WHERE `username` = ?", username )
	
	if ( not query ) then
		local accountID = exports.database:insert_id( "INSERT INTO `accounts` (`username`, `password`) VALUES (?, ?)", username, exports.security:hashString( password ) )
		
		if ( accountID ) then
			return true
		else
			return -2
		end
	else
		return -1
	end
end

addEvent( "accounts:login", true )
addEventHandler( "accounts:login", root,
	function( username, password )
		if ( source ~= client ) then
			return
		end
		
		if ( username ) and ( password ) then
			local status = login( client, username, password )
			
			if ( not status ) then
				triggerClientEvent( client, "messages:create", client, "Username and/or passwors is incorrect. Please try again.", "login" )
			else
				triggerClientEvent( client, "accounts:onLogin", client )
				
				updateCharacters( client )
			end
		else
			triggerClientEvent( client, "messages:create", client, "Oops, something went wrong. Please try again.", "login" )
		end
	end
)

addEvent( "accounts:register", true )
addEventHandler( "accounts:register", root,
	function( username, password )
		if ( source ~= client ) then
			return
		end
		
		if ( username ) and ( password ) then
			local status = register( username, password )
			
			if ( status == -1 ) then
				triggerClientEvent( client, "messages:create", client, "An account with this username already exists. Please try another name.", "login" )
			elseif ( status == -2 ) then
				triggerClientEvent( client, "messages:create", client, "Oops, something went wrong. Please try again.", "login" )
			else
				triggerClientEvent( client, "accounts:onRegister", client )
			end
		else
			triggerClientEvent( client, "messages:create", client, "Oops, something went wrong. Please try again.", "login" )
		end
	end
)

addEvent( "accounts:ready", true )
addEventHandler( "accounts:ready", root,
	function( )
		if ( source ~= client ) then
			return
		end
		
		local accountID = tonumber( getElementData( client, "database:id" ) )
		
		if ( not accountID ) then
			triggerClientEvent( client, "accounts:showLogin", client )
			
			fadeCamera( client, true )
		else
			if ( not getElementData( client, "player:playing" ) ) then
				exports.messages:createMessage( client, "Loading characters. Please wait.", "selection", nil, true, true )
				
				triggerClientEvent( client, "accounts:showCharacterSelection", client )
				
				updateCharacters( client )
				
				exports.messages:destroyMessage( client, "selection" )
				
				fadeCamera( client, true )
			end
		end
	end
)