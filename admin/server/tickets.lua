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

local tickets = { }

function getTickets( )
	return tickets
end

function createTicket( sourcePlayer, targetPlayer, message, type )
	local day = ( getRealTime( ).monthday < 10 and "0" or "" ) .. getRealTime( ).monthday
	local month = ( getRealTime( ).month + 1 < 10 and "0" or "" ) .. getRealTime( ).month + 1
	local year = ( getRealTime( ).year + 1900 < 10 and "0" or "" ) .. getRealTime( ).year + 1900
	local hour = ( getRealTime( ).hour < 10 and "0" or "" ) .. getRealTime( ).hour
	local minute = ( getRealTime( ).minute < 10 and "0" or "" ) .. getRealTime( ).minute
	local second = ( getRealTime( ).second < 10 and "0" or "" ) .. getRealTime( ).second
	local dateAndTime = day .. "/" .. month .. "/" .. year .. " " .. hour .. ":" .. minute .. ":" .. second
	local jsonSafePlayers = { }
	
	for _, player in ipairs( getElementsByType( "player" ) ) do
		local x, y, z = getElementPosition( player )
		local distance = getDistanceBetweenPoints3D( x, y, z, getElementPosition( sourcePlayer ) )
		
		if ( distance < 75 ) then
			table.insert( jsonSafePlayers, { name = exports.common:getPlayerName( player ), account = exports.common:getAccountName( player ), distance = distance } )
		end
	end
	
	local id = exports.database:insert_id( "INSERT INTO `ticket_logs` (`source_character_id`, `target_character_id`, `message`, `type`, `players`, `location`, `time`) VALUES (?, ?, ?, ?, ?, ?, ?)", exports.common:getCharacterID( sourcePlayer ), exports.common:getCharacterID( targetPlayer or sourcePlayer ), message and message:gsub( "\r\n", " " ) or "", type or 1000, toJSON( jsonSafePlayers ), getElementZoneName( sourcePlayer ) .. ", " .. getElementZoneName( sourcePlayer, true ), dateAndTime )
	
	if ( id ) then
		return loadTicket( id )
	end
	
	return false
end

function loadTicket( id )
	local ticket = exports.database:query_single( "SELECT * FROM `ticket_logs` WHERE `id` = ?", id )
	
	if ( ticket ) then
		tickets[ id ] = {
			sourcePlayer = exports.common:getPlayerByCharacterID( ticket.source_character_id ),
			targetPlayer = exports.common:getPlayerByCharacterID( ticket.target_character_id ),
			message = ticket.message,
			type = ticket.type,
			players = fromJSON( ticket.players ),
			location = ticket.location,
			time = ticket.time,
			assignedTo = ticket.assigned_to,
			assignedTime = ticket.assigned_time
		}
		
		if ( ticket.assigned_to == 0 ) then
			for _, player in ipairs( exports.common:getPriorityPlayers( ) ) do
				triggerClientEvent( player, "admin:update_tickets", player, tickets, true )
			end
		else
			local player = exports.common:getPlayerByAccountID( ticket.assigned_to )
			
			if ( player ) then
				triggerClientEvent( player, "admin:update_tickets", player, tickets, true )
			end
		end
		
		return true
	end
	
	return false
end

function destroyTicket( id, closeCode )
	if ( tickets[ id ] ) then
		tickets[ id ] = nil
		
		exports.database:execute( "UPDATE `ticket_logs` SET `closed_time` = NOW(), `closed_state` = ? WHERE `id` = ?", closeCode or 99, id )
		
		for _, player in ipairs( exports.common:getPriorityPlayers( ) ) do
			triggerClientEvent( player, "admin:update_tickets", player, tickets )
		end
		
		return true
	end
	
	return false
end

function assignTicket( id, player )
	if ( tickets[ id ] ) then
		tickets[ id ].assignedTo = exports.common:getAccountID( player )
		
		for _, player in ipairs( exports.common:getPriorityPlayers( ) ) do
			triggerClientEvent( player, "admin:update_tickets", player, tickets )
		end
		
		if ( exports.database:execute( "UPDATE `ticket_logs` SET `assigned_time` = NOW(), `assigned_to` = ? WHERE `id` = ?", exports.common:getAccountID( player ), id ) ) then
			return loadTicket( id )
		end
	end
	
	return false
end

function updateTickets( player )
	triggerClientEvent( player, "admin:update_tickets", player, tickets )
end

function getAmountOfTicketsByPlayer( player )
	return exports.database:query_single( "SELECT COUNT(*) AS `count` FROM `ticket_logs` WHERE `assigned_to` = ?", exports.common:getAccountID( player ) ).count
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		setTimer( function( )
			local query = exports.database:query( "SELECT * FROM `ticket_logs` WHERE `closed_state` = '0' ORDER BY `id` ASC, `assigned_to` ASC, `type` ASC" )
			
			if ( query ) then
				for _, data in ipairs( query ) do
					loadTicket( data.id )
				end
			end
		end, 500, 1 )
	end
)

function playerChanged( player )
	local player = player or source
	
	if ( player ) then
		for id, data in pairs( tickets ) do
			if ( data.targetPlayer == source ) then
				tickets[ id ].targetPlayer = getPlayerName( source )
			end
			
			--[[if ( data.sourcePlayer == source ) then
				destroyTicket( id )
			end]]
		end
		
		return true
	end
	
	return false
end
addEventHandler( "onPlayerQuit", root, playerChanged )
addEvent( "admin:ticket_left", true )
addEventHandler( "admin:ticket_left", root, playerChanged )

addEvent( "admin:ticket_close", true )
addEventHandler( "admin:ticket_close", root,
	function( id, reason, isSpam )
		if ( source ~= client ) then
			return
		end
		
		if ( tickets[ id ] ) then
			if ( tickets[ id ].assignedTo == 0 ) then
				assignTicket( id, client )
			else
				if ( tickets[ id ].assignedTo ~= exports.common:getAccountID( client ) ) then
					outputChatBox( "This is not your ticket!", client, 230, 95, 95 )
				end
			end
			
			if ( isElement( tickets[ id ].sourcePlayer ) ) then
				exports.messages:createMessage( tickets[ id ].sourcePlayer, reason, "ticket-closed" )
				
				if ( isPedDead( tickets[ id ].sourcePlayer ) ) and ( getElementData( tickets[ id ].sourcePlayer, "player:waiting" ) ) then
					exports.security:modifyElementData( tickets[ id ].sourcePlayer, "player:waiting", nil, true )
					triggerClientEvent( tickets[ id ].sourcePlayer, "realism:death_scene", tickets[ id ].sourcePlayer )
				end
			end
			
			destroyTicket( id, isSpam and 2 or 1 )
			
			outputChatBox( "Ticket marked as resolved!", client, 95, 230, 95 )
		else
			outputChatBox( "This ticket does not exist anymore. Sorry!", client, 230, 95, 95 )
			
			triggerClientEvent( client, "admin:update_tickets", client, tickets )
		end
	end
)

addEvent( "admin:ticket_assign", true )
addEventHandler( "admin:ticket_assign", root,
	function( id, reason )
		if ( source ~= client ) then
			return
		end
		
		if ( tickets[ id ] ) then
			if ( assignTicket( id, client ) ) then
				outputChatBox( "Ticket assigned to you!", client, 95, 230, 95 )
			end
		else
			outputChatBox( "This ticket does not exist anymore. Sorry!", client, 230, 95, 95 )
			
			triggerClientEvent( client, "admin:update_tickets", client, tickets )
		end
	end
)

addEvent( "admin:new_ticket", true )
addEventHandler( "admin:new_ticket", root,
	function( targetName, message, type )
		if ( source ~= client ) or ( not targetName ) or ( not message ) or ( not type ) then
			return
		end
		
		while ( message:find( "  " ) ) do
			message = message:gsub( "  ", " " )
		end
		
		if ( message:len( ) >= 15 ) and ( message:len( ) <= 1000 ) then
			local target = exports.common:getPlayerFromPartialName( targetName, client )
			
			if ( not target ) then
				target = client
			end
			
			if ( createTicket( client, target, message, type ) ) then
				triggerClientEvent( client, "admin:hide_ticket_ui", client )
				exports.messages:createMessage( client, "You have successfully submitted your ticket. You will be contacted by an administrator soon.", "new-ticket-msg" )
			else
				outputChatBox( "Could not create a ticket, please try again.", client, 230, 95, 95 )
			end
		else
			outputChatBox( "Message length is not sufficient. Minimum length is 15 and maximum length is 1000 characters.", client, 230, 95, 95 )
		end
	end
)

addEvent( "admin:goto_player", true )
addEventHandler( "admin:goto_player", root,
	function( id, which )
		if ( source ~= client ) then
			return
		end
		
		if ( tickets[ id ] ) then
			local player = which == "source" and tickets[ id ].sourcePlayer or tickets[ id ].targetPlayer
			
			if ( player ~= client ) then
				if ( isElement( player ) ) then
					if ( teleportPlayer( client, player ) ) then
						outputChatBox( "You teleported to " .. exports.common:getPlayerName( player ) .. ".", client, 230, 180, 95 )
					else
						outputChatBox( "Could not teleport to that player, try again.", client, 230, 95, 95 )
					end
				else
					outputChatBox( "That player does not exist anymore.", client, 230, 95, 95 )
				end
			end
		else
			outputChatBox( "This ticket does not exist anymore. Sorry!", client, 230, 95, 95 )
			
			triggerClientEvent( client, "admin:update_tickets", client, tickets )
		end
	end
)