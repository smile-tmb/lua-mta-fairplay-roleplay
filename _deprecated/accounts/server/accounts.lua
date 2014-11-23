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
		
		triggerClientEvent( player, "accounts:onLogin", player )
	end
end

function register( player, username, password )
	if ( getElementType( player ) ~= "player" ) then
		return false
	end
	
	local query = exports.database:query_single( "SELECT NULL FROM `accounts` WHERE `username` = ?", username )
	
	outputConsole( "Username: " .. username )
	outputConsole( "Password: " .. password )
	
	if ( query ) then
		local accountID = exports.database:insert_id( "INSERT INTO `accounts` (`username`, `password`) VALUES (?, ?)", username, exports.security:hashString( password ) )
		
		if ( accountID ) then
			return true
		else
			return -1
		end
	end
end

addEvent( "accounts:login", true )
addEventHandler( "accounts:login", root,
	function( username, usernameKey, password, passwordKey )
		if ( source ~= client ) then
			return
		end
		
		local username = exports.security:decryptNetworkData( username, table.concat( usernameKey ) )
		local password = exports.security:decryptNetworkData( password, table.concat( passwordKey ) )
		
		login( client, username, password )
	end
)

addEvent( "accounts:register", true )
addEventHandler( "accounts:register", root,
	function( username, usernameKey, password, passwordKey )
		if ( source ~= client ) then
			return
		end
		
		local username = exports.security:decryptNetworkData( username, table.concat( usernameKey ) )
		local password = exports.security:decryptNetworkData( password, table.concat( passwordKey ) )
		
		if ( username ) and ( password ) then
			local status = register( client, username, password )
			
			if ( status ~= true ) then
				triggerClientEvent( client, "accounts:onRegisterError", client, status )
			else
				triggerClientEvent( client, "accounts:onRegister", client )
			end
		else
			triggerClientEvent( client, "accounts:onRegisterError", client, -1 )
		end
	end
)

addEvent( "accounts:ready", true )
addEventHandler( "accounts:ready", root,
	function( )
		if ( source ~= client ) then
			return
		end
		
		if ( not getElementData( client, "database:id" ) ) then
			triggerClientEvent( client, "accounts:showLogin", client )
		end
	end
)