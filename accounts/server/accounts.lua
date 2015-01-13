--[[
	The MIT License (MIT)

	Copyright (c) 2014 Socialz (+ soc-i-alz GitHub organization)

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]

local _get = get

function get( id )
	return exports.database:query_single( "SELECT * FROM `accounts` WHERE `id` = ?", id )
end

function new( username, password )
	local id = exports.database:insert_id( "INSERT INTO `accounts` (`username`, `password`) VALUES (?, ?)", username, exports.security:hashString( password ) )

	if ( id ) then
		local query = exports.database:query_single( "SELECT COUNT(*) AS `count` FROM `accounts`" )

		if ( query ) and ( query.count == 1 ) then
			local playerLevel = 0

			for level in pairs( exports.common:getLevels( ) ) do
				if ( exports.common:getLevelPriority( level ) > exports.common:getLevelPriority( playerLevel ) ) then
					playerLevel = level
				end
			end

			exports.database:execute( "UPDATE `accounts` SET `level` = ? WHERE `id` = ?", playerLevel, id )
		end

		return id
	end

	return false
end

function login( player, username, password )
	if ( getElementType( player ) ~= "player" ) then
		return false
	end
	
	local account = exports.database:query_single( "SELECT * FROM `accounts` WHERE `username` = ? AND `password` = ?", username, exports.security:hashString( password ) )
	
	if ( account ) then
		if ( account.last_ip ~= getPlayerIP( player ) ) or ( account.last_serial ~= getPlayerSerial( player ) ) then
			exports.database:execute( "UPDATE `accounts` SET `last_login` = NOW( ), `last_ip` = ?, `last_serial` = ? WHERE `id` = ?", getPlayerIP( player ), getPlayerSerial( player ), account.id )
		end
		
		exports.security:modifyElementData( player, "database:id", account.id, true )
		exports.security:modifyElementData( player, "account:username", account.username, true )
		exports.security:modifyElementData( player, "account:level", account.level, true )
		exports.security:modifyElementData( player, "account:duty", true, true )
		exports.security:modifyElementData( player, "player:name", getPlayerName( player ), true )
		
		triggerClientEvent( player, "accounts:onLogin", player )
		triggerClientEvent( player, "admin:showHUD", player )
		
		return true
	end
	
	return false
end

function logout( player )
	characterSelection( player )
	
	exports.database:execute( "UPDATE `accounts` SET `last_action` = NOW( ) WHERE `id` = ?", exports.common:getAccountID( player ) )
	
	setPlayerName( player, getElementData( player, "player:name" ) )
	
	removeElementData( player, "database:id" )
	removeElementData( player, "account:username" )
	removeElementData( player, "account:level" )
	removeElementData( player, "account:duty" )
	removeElementData( player, "player:name" )
	
	triggerClientEvent( player, "superman:stop", player )
	
	spawnPlayer( player, 0, 0, 0 )
	setElementDimension( player, 6000 )
	
	setCameraMatrix( player, 0, 0, 100, 100, 100, 100 )
	
	triggerClientEvent( player, "accounts:onLogout.characters", player )
	triggerClientEvent( player, "accounts:onLogout.accounts", player )
	triggerClientEvent( player, "admin:hideHUD", player )
end

function register( username, password )
	local query = exports.database:query_single( "SELECT NULL FROM `accounts` WHERE `username` = ?", username )
	
	if ( not query ) then
		local accountID = exports.database:insert_id( "INSERT INTO `accounts` (`username`, `password`) VALUES (?, ?)", username, exports.security:hashString( password ) )
		
		if ( accountID ) then
			return accountID
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
				triggerClientEvent( client, "messages:create", client, "Username and/or password is incorrect. Please try again.", "login" )
			else
				triggerClientEvent( client, "accounts:onLogin", client )
				
				updateCharacters( client )
			end
		else
			triggerClientEvent( client, "messages:create", client, "Oops, something went wrong. Please try again.", "login" )
		end
	end
)

addEvent( "accounts:logout", true )
addEventHandler( "accounts:logout", root,
	function( )
		if ( source ~= client ) then
			return
		end
		
		logout( client )
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
		
		local accountID = exports.common:getAccountID( client )
		
		if ( not accountID ) then
			triggerClientEvent( client, "accounts:showLogin", client )
			
			fadeCamera( client, true )
		else
			if ( not exports.common:isPlayerPlaying( client ) ) then
				exports.messages:createMessage( client, "Loading characters. Please wait.", "selection", nil, true, true )
				
				triggerClientEvent( client, "accounts:showCharacterSelection", client )
				
				updateCharacters( client )
				
				exports.messages:destroyMessage( client, "selection" )
				
				fadeCamera( client, true )
			end
		end
		
		if ( not exports.common:isPlayerPlaying( client ) ) then
			triggerClientEvent( client, "accounts:showView", client )
		end
		
		if ( not exports.common:getPlayerID( client ) ) then
			givePlayerID( client )
		end
		
		setPlayerHudComponentVisible( client, "all", false )
		setPlayerHudComponentVisible( client, "clock", true )
	end
)