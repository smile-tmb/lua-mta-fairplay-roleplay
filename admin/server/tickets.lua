local tickets = { }

function getTickets( )
	return tickets
end

function createTicket( sourcePlayer, targetPlayer, message, type )
	local id = exports.common:nextIndex( tickets )
	
	local day = ( getRealTime( ).monthday < 10 and "0" or "" ) .. getRealTime( ).monthday
	local month = ( getRealTime( ).month + 1 < 10 and "0" or "" ) .. getRealTime( ).month + 1
	local year = ( getRealTime( ).year + 1900 < 10 and "0" or "" ) .. getRealTime( ).year + 1900
	local hour = ( getRealTime( ).hour < 10 and "0" or "" ) .. getRealTime( ).hour
	local minute = ( getRealTime( ).minute < 10 and "0" or "" ) .. getRealTime( ).minute
	local second = ( getRealTime( ).second < 10 and "0" or "" ) .. getRealTime( ).second
	
	local dateAndTime = day .. "/" .. month .. "/" .. year .. " " .. hour .. ":" .. minute .. ":" .. second
	
	tickets[ id ] = {
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
	
	for _, player in ipairs( exports.common:getPriorityPlayers( ) ) do
		triggerClientEvent( player, "admin:update_tickets", player, tickets, true )
	end
	
	exports.database:execute( "INSERT INTO `ticket_logs` (`source_character_id`, `target_character_id`, `message`, `type`, `players`, `location`, `time`) VALUES (?, ?, ?, ?, ?, ?, ?)", exports.common:getCharacterID( sourcePlayer ), exports.common:getCharacterID( targetPlayer or sourcePlayer ), tickets[ id ].message, tickets[ id ].type, toJSON( jsonSafePlayers ), tickets[ id ].location, tickets[ id ].time )
	
	return true
end

function destroyTicket( id )
	if ( tickets[ id ] ) then
		tickets[ id ] = nil
		
		for _, player in ipairs( exports.common:getPriorityPlayers( ) ) do
			triggerClientEvent( player, "admin:update_tickets", player, tickets )
		end
		
		return true
	end
	
	return false
end

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
	function( id, reason )
		if ( source ~= client ) then
			return
		end
		
		if ( tickets[ id ] ) then
			if ( isElement( tickets[ id ].sourcePlayer ) ) then
				exports.messages:createMessage( tickets[ id ].sourcePlayer, reason, "ticket-closed" )
				
				if ( isPedDead( tickets[ id ].sourcePlayer ) ) then
					triggerClientEvent( tickets[ id ].sourcePlayer, "realism:death_scene", tickets[ id ].sourcePlayer )
					outputChatBox( "Please file a new ticket regarding your death, and explain your issue better.", tickets[ id ].sourcePlayer, 230, 95, 95, false )
				end
			end
			
			destroyTicket( id )
			
			outputChatBox( "Ticket marked as resolved!", client, 95, 230, 95, false )
		else
			outputChatBox( "This ticket does not exist anymore. Sorry!", client, 230, 95, 95, false )
			
			triggerClientEvent( client, "admin:update_tickets", client, tickets )
		end
	end
)