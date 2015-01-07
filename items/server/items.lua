data = { }

function getItems( player )
	return data[ player ] and data[ player ].items or { }
end

function loadItems( player )
	data[ player ] = {
		items = { }
	}
	
	exports.security:modifyElementData( player, "character:weight", 0, true )
	exports.security:modifyElementData( player, "character:max_weight", 10, true )
	
	local query = exports.database:query( "SELECT * FROM `inventory` WHERE `character_id` = ?", exports.common:getCharacterID( player ) )
	
	if ( query ) then
		for result, row in ipairs( query ) do
			if ( getItem( row.item_id ) ) then
				giveItem( player, row.item_id, row.value, row.id, row.ringtone_id, row.messagetone_id )
			end
		end
		
		loadWeapons( player )
	end
end

function giveItem( player, itemID, value, dbID, ringtoneID, messagetoneID, ignoreWeight )
	if ( getItemList( itemID ) ) then
		if ( not ignoreWeight ) and ( isElement( player ) ) and ( tonumber( getElementData( player, "character:weight" ) ) + getItemWeight( itemID ) > tonumber( getElementData( player, "character:max_weight" ) ) ) then
			return false
		end
		
		if ( not value ) then
			value = ""
		end
		
		dbID = dbID or exports.database:insert_id( "INSERT INTO `inventory` (`character_id`, `item_id`, `value`, `ringtone_id`, `messagetone_id`, `created_time`) VALUES (?, ?, ?, ?, ?, NOW())", isElement( player ) and exports.common:getCharacterID( player ) or player, itemID, value, ringtoneID or 1, messagetoneID or 1 )
		
		if ( isElement( player ) ) then
			if ( itemID == 8 ) then
				exports.security:modifyElementData( player, "character:max_weight", 20, true )
			elseif ( itemID == 9 ) then
				exports.security:modifyElementData( player, "character:max_weight", 30, true )
			end
			
			exports.security:modifyElementData( player, "character:weight", tonumber( getElementData( player, "character:weight" ) ) + getItemWeight( itemID ), true )
			
			table.insert( data[ player ].items, { id = dbID, itemID = itemID, value = value, ringtoneID = ringtoneID or 1, messagetoneID = messagetoneID or 1 } )
			
			triggerClientEvent( player, "items:update", player, getItems( player ) )
			
			loadWeapons( player )
		end
		
		return true
	else
		return false
	end
end

function takeItem( player, id )
	local item = { }
	
	if ( data[ player ] ) then
		for index, values in pairs( data[ player ].items ) do
			if ( values.id == id ) then
				item = values
				table.remove( data[ player ].items, index )
				break
			end
		end
		
		exports.database:execute( "DELETE FROM `inventory` WHERE `id` = ?", id )
		
		loadItems( player )
		loadWeapons( player )
		
		return true
	end
	
	return false
end

function hasItem( player, itemID, value, dbID )
	loadItems( player )
	
	if ( getItemList( )[ itemID ] ) then
		for _, item in pairs( data[ player ].items ) do
			if ( tonumber( item.item_id ) == tonumber( itemID ) ) then
				if ( not value ) then
					return true, item.value
				else
					if ( value ) and ( tostring( item.value ) == tostring( value ) ) then
						if ( not dbID ) then
							return true
						else
							if ( tostring( item.db_id ) == tostring( dbID ) ) then
								return true
							end
						end
					else
						if ( dbID ) then
							if ( tostring( item.db_id ) == tostring( dbID ) ) then
								return true, item.value
							end
						end
					end
				end
			end
		end
	end
	
	return false
end

function getPlayerItemValue( player, itemID, dbID )
	local itemFound, itemValue = hasItem( player, itemID, nil, dbID )
	
	if ( itemFound ) then
		return itemValue
	end
end

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		for _, player in ipairs( getElementsByType( "player" ) ) do
			if ( exports.common:isPlayerPlaying( player ) ) then
				exports.security:modifyElementData( player, "character:weight", 0, true )
				exports.security:modifyElementData( player, "character:max_weight", 10, true )
			end
			
			takeAllWeapons( player )
		end
	end
)

addEvent( "items:get", true)
addEventHandler( "items:get", root,
	function( )
		if ( source ~= client ) then
			return
		end
		
		loadItems( client )
	end
)

addEvent( "items:synchronize", true)
addEventHandler( "items:synchronize", root,
	function( )
		if ( source ~= client ) then
			return
		end
		
		triggerClientEvent( client, "inventory:synchronize", client, data[ client ].items )
	end
)

addCommandHandler( "giveitem",
	function( player, cmd, targetPlayer, itemID, ... )
		if ( exports.common:isPlayerServerAdmin( player ) ) then
			local itemID = tonumber( itemID )
			
			if ( not targetPlayer ) or ( not itemID ) or ( ( itemID ) and ( itemID <= 0 ) ) then
				outputChatBox( "SYNTAX: /" .. cmd .. " [partial player name] [item id] <[value]>", player, 230, 180, 95, false )
				return
			else
				if ( ... ) then
					value = table.concat( { ... }, " " )
				end
				
				local targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )
				
				if ( not targetPlayer ) then
					outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95, false )
				else
					if ( getItemList( )[ itemID ] ) then
						if ( data[ targetPlayer ] ) then
							if ( ( tonumber( getElementData( targetPlayer, "character:weight" ) ) + getItemWeight( itemID ) ) <= tonumber( getElementData( targetPlayer, "character:max_weight" ) ) ) then
								if ( giveItem( targetPlayer, itemID, value ) ) then
									outputChatBox( "Gave " .. exports.common:getPlayerName( targetPlayer ) .. " item " .. getItemName( itemID ) .. " (" .. itemID .. ").", player, 95, 230, 95, false )
								else
									outputChatBox( "Error occurred - 0x0220.", player, 230, 95, 95, false )
								end
							else
								outputChatBox( "That player does not have enough space for that item.", player, 230, 95, 95, false )
							end
						else
							outputChatBox( "That player doesn't have item data initialized yet.", player, 230, 95, 95, false )
						end
					else
						outputChatBox( "Invalid item ID.", player, 230, 95, 95, false )
					end
				end
			end
		end
	end
)

addCommandHandler( "takeitem",
	function( player, cmd, targetPlayer, itemID, value, dbID )
		if ( exports.common:isPlayerServerAdmin( player ) ) then
			local itemID = tonumber( itemID )
			local dbID = tonumber( dbID )
			
			if ( not targetPlayer ) or ( not itemID ) or ( ( itemID ) and ( itemID <= 0 ) ) or ( ( value ) and ( string.len( value ) < 2 ) ) or ( ( dbID ) and ( dbID <= 0 ) ) then
				outputChatBox( "SYNTAX: /" .. cmd .. " [partial player name] [item id] <[value]> <[entry id]>", player, 230, 180, 95, false )
				return
			else
				local targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )
				if ( not targetPlayer ) then
					outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95, false )
				else
					if ( getItemList( )[ itemID ] ) then
						if ( data[ targetPlayer ] ) then
							local deleted, itemValue = takeItem( targetPlayer, itemID, value, dbID )
							
							if ( deleted ) then
								local vehicle = getPedOccupiedVehicle( targetPlayer )
								
								if ( vehicle ) and ( getVehicleController( vehicle ) == targetPlayer ) and ( exports.vehicles:getVehicleRealID( vehicle ) == tonumber( itemValue ) ) then
									exports.security:modifyElementData( vehicle, "vehicle:engine", false, true )
									setVehicleEngineState( vehicle, false )
								end
								
								outputChatBox( "Took " .. getItemName( itemID ) .. " from " .. exports.common:getPlayerName(targetPlayer) .. ".", player, 95, 230, 95, false )
							else
								outputChatBox( "That player doesn't have an item.", player, 230, 95, 95, false )
							end
						else
							outputChatBox( "That player doesn't have item data initialized yet.", player, 230, 95, 95, false )
						end
					else
						outputChatBox( "Invalid item ID.", player, 230, 95, 95, false )
					end
				end
			end
		end
	end
)