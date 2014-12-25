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
	local ticket = {
		sourcePlayer = sourcePlayer,
		targetPlayer = targetPlayer or sourcePlayer,
		message = message and message:gsub( "\r\n", " " ) or "",
		type = type or 1000,
		players = { },
		location = getElementZoneName( sourcePlayer ) .. ", " .. getElementZoneName( sourcePlayer, true ),
		time = dateAndTime
	}
	
	local jsonSafePlayers = { }
	
	for _, player in ipairs( getElementsByType( "player" ) ) do
		local x, y, z = getElementPosition( player )
		local distance = getDistanceBetweenPoints3D( x, y, z, getElementPosition( sourcePlayer ) )
		
		if ( distance < 75 ) then
			local data = { name = exports.common:getPlayerName( player ), account = exports.common:getAccountName( player ), player = player, distance = distance }
			
			table.insert( tickets[ id ].players, data )
			
			data.player = nil
			
			table.insert( jsonSafePlayers, data )
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
			time = ticket.time
		}
		
		for _, player in ipairs( exports.common:getPriorityPlayers( ) ) do
			triggerClientEvent( player, "admin:update_tickets", player, tickets, true )
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
		tickets[ id ].assignedTo = player
		tickets[ id ].assignedTime = getRealTime( ).timestamp
		
		for _, player in ipairs( exports.common:getPriorityPlayers( ) ) do
			triggerClientEvent( player, "admin:update_tickets", player, tickets )
		end
		
		return exports.database:execute( "UPDATE `ticket_logs` SET `assigned_time` = NOW() AND `assigned_to` = ? WHERE `id` = ?", tickets[ id ].assignedTime, exports.common:getAccountID( player ), id )
	end
	
	return false
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		setTimer( function( )
			for _, data in ipairs( exports.database:query( "SELECT * FROM `ticket_logs` WHERE `closed_state` = '0'" ) ) do
				loadTicket( data.id )
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
			
			if ( data.sourcePlayer == source ) then
				destroyTicket( id )
			end
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
			if ( not tickets[ id ].assignedTo ) then
				assignTicket( id, player )
			else
				if ( tickets[ id ].assignedTo ~= client ) then
					outputChatBox( "This is not your ticket!", client, 230, 95, 95, false )
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
			
			outputChatBox( "Ticket marked as resolved!", client, 95, 230, 95, false )
		else
			outputChatBox( "This ticket does not exist anymore. Sorry!", client, 230, 95, 95, false )
			
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
				outputChatBox( "Ticket assigned to you!", client, 95, 230, 95, false )
			end
		else
			outputChatBox( "This ticket does not exist anymore. Sorry!", client, 230, 95, 95, false )
			
			triggerClientEvent( client, "admin:update_tickets", client, tickets )
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
						outputChatBox( "You teleported to " .. exports.common:getPlayerName( player ) .. ".", client, 230, 180, 95, false )
					else
						outputChatBox( "Could not teleport to that player, try again.", client, 230, 95, 95, false )
					end
				else
					outputChatBox( "That player does not exist anymore.", client, 230, 95, 95, false )
				end
			end
		else
			outputChatBox( "This ticket does not exist anymore. Sorry!", client, 230, 95, 95, false )
			
			triggerClientEvent( client, "admin:update_tickets", client, tickets )
		end
	end
)