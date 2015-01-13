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

local items = { }

local function getID( element )
	if ( getElementType( element ) == "player" ) then
		if ( exports.common:isPlayerPlaying( element ) ) then
			return exports.common:getCharacterID( element )
		end
	elseif ( getElementType( element ) == "vehicle" ) then
		return exports.common:getRealVehicleID( element )
	end

	return false
end

function getItems( element )
	return items[ element ] or { }
end

function loadItems( element )
	local ownerID = getID( element )

	if ( ownerID ) then
		items[ element ] = { }
		
		local result = exports.database:query( "SELECT * FROM `inventory` WHERE `owner_id` = ?", ownerID )
		
		for _, item in ipairs( result ) do
			table.insert( items[ element ], { id = item.id, itemID = item.item_id, itemValue = item.item_value } )
		end
		
		if ( getElementType( element ) == "player" ) then
			loadWeapons( element )
			triggerClientEvent( element, "items:update", element, getItems( element ) )
		end
		
		return true
	end

	return false
end

function giveItem( element, itemID, itemValue )
	local ownerID = getID( element )

	if ( ownerID ) then
		local id = exports.database:insert_id( "INSERT INTO `inventory` (`owner_id`, `item_id`, `item_value`) VALUES (?, ?, ?)", ownerID, itemID, itemValue )

		if ( id ) then
			table.insert( items[ element ], { id = id, itemID = itemID, itemValue = itemValue } )
			
			loadItems( element )

			return true
		end
	end

	return false
end

function takeItem( element, id )
	local ownerID = getID( element )

	if ( ownerID ) then
		local item, index = hasItem( element, false, false, id )

		if ( item ) then
			if ( exports.database:execute( "DELETE FROM `inventory` WHERE `id` = ? AND `owner_id` = ?", id, ownerID ) ) then
				table.remove( items[ element ], index )
				
				loadItems( element )
				
				return true
			end
		end
	end

	return false
end

function hasItem( element, itemID, itemValue, id )
	for index, values in ipairs( getItems( element ) ) do
		if ( ( not id ) and ( values.itemID == itemID ) and ( ( not itemValue ) or ( tostring( values.itemValue ) == tostring( itemValue ) ) ) ) or ( ( id ) and ( values.id == id ) ) then
			return true, index, values
		end
	end

	return false
end

addEvent( "items:get", true )
addEventHandler( "items:get", root,
	function( )
		if ( source ~= client ) then
			return
		end

		loadItems( client )

		triggerClientEvent( client, "items:update", client, getItems( client ) )
	end
)

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		for _, player in ipairs( getElementsByType( "player" ) ) do
			takeAllWeapons( player )
		end
	end
)

addCommandHandler( "giveitem",
	function( player, cmd, targetPlayer, itemID, ... )
		if ( exports.common:isPlayerServerAdmin( player ) ) then
			local itemID = tonumber( itemID )
			
			if ( not targetPlayer ) or ( not itemID ) or ( ( itemID ) and ( itemID <= 0 ) ) then
				outputChatBox( "SYNTAX: /" .. cmd .. " [partial player name] [item id] <[value]>", player, 230, 180, 95 )
				return
			else
				if ( ... ) then
					value = table.concat( { ... }, " " )
				end
				
				local targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )
				
				if ( not targetPlayer ) then
					outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95 )
				else
					if ( getItemList( )[ itemID ] ) then
						if ( items[ targetPlayer ] ) then
							value = value or getItemValue( itemID )
							
							if ( giveItem( targetPlayer, itemID, value ) ) then
								outputChatBox( "Gave " .. exports.common:getPlayerName( targetPlayer ) .. " item " .. getItemName( itemID ) .. " (" .. itemID .. ").", player, 95, 230, 95 )
								outputChatBox( "You were given a " .. getItemName( itemID ) .. " (" .. itemID .. ").", player, 95, 230, 95 )
							else
								outputChatBox( "Error occurred (0x0000FE).", player, 230, 95, 95 )
							end
						else
							outputChatBox( "That player doesn't have item data initialized yet.", player, 230, 95, 95 )
						end
					else
						outputChatBox( "Invalid item ID.", player, 230, 95, 95 )
					end
				end
			end
		end
	end
)

addCommandHandler( "takeitem",
	function( player, cmd, targetPlayer, itemID, value )
		if ( exports.common:isPlayerServerAdmin( player ) ) then
			local itemID = tonumber( itemID )
			
			if ( not targetPlayer ) or ( not itemID ) or ( ( itemID ) and ( itemID <= 0 ) ) or ( ( value ) and ( string.len( value ) < 2 ) ) then
				outputChatBox( "SYNTAX: /" .. cmd .. " [partial player name] [item id] <[value]>", player, 230, 180, 95 )
				return
			else
				local targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )

				if ( not targetPlayer ) then
					outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95 )
				else
					if ( getItemList( )[ itemID ] ) then
						if ( items[ targetPlayer ] ) then
							local item, index, values = hasItem( targetPlayer, itemID, value )

							if ( item ) then
								if ( takeItem( targetPlayer, values.id ) ) then
									local vehicle = getPedOccupiedVehicle( targetPlayer )
									
									if ( vehicle ) and ( getVehicleController( vehicle ) == targetPlayer ) and ( exports.vehicles:getVehicleRealID( vehicle ) == values.itemValue ) then
										exports.security:modifyElementData( vehicle, "vehicle:engine", false, true )
										setVehicleEngineState( vehicle, false )
									end
									
									outputChatBox( "Took " .. getItemName( itemID ) .. " from " .. exports.common:getPlayerName(targetPlayer) .. ".", player, 95, 230, 95 )
								else
									outputChatBox( "Error occurred (0x0000FF).", player, 230, 95, 95 )
								end
							else
								outputChatBox( "That player doesn't have an item.", player, 230, 95, 95 )
							end
						else
							outputChatBox( "That player doesn't have item data initialized yet.", player, 230, 95, 95 )
						end
					else
						outputChatBox( "Invalid item ID.", player, 230, 95, 95 )
					end
				end
			end
		end
	end
)

--[[
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
				outputChatBox( "SYNTAX: /" .. cmd .. " [partial player name] [item id] <[value]>", player, 230, 180, 95 )
				return
			else
				if ( ... ) then
					value = table.concat( { ... }, " " )
				end
				
				local targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )
				
				if ( not targetPlayer ) then
					outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95 )
				else
					if ( getItemList( )[ itemID ] ) then
						if ( data[ targetPlayer ] ) then
							if ( ( tonumber( getElementData( targetPlayer, "character:weight" ) ) + getItemWeight( itemID ) ) <= tonumber( getElementData( targetPlayer, "character:max_weight" ) ) ) then
								if ( giveItem( targetPlayer, itemID, value ) ) then
									outputChatBox( "Gave " .. exports.common:getPlayerName( targetPlayer ) .. " item " .. getItemName( itemID ) .. " (" .. itemID .. ").", player, 95, 230, 95 )
								else
									outputChatBox( "Error occurred - 0x0220.", player, 230, 95, 95 )
								end
							else
								outputChatBox( "That player does not have enough space for that item.", player, 230, 95, 95 )
							end
						else
							outputChatBox( "That player doesn't have item data initialized yet.", player, 230, 95, 95 )
						end
					else
						outputChatBox( "Invalid item ID.", player, 230, 95, 95 )
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
				outputChatBox( "SYNTAX: /" .. cmd .. " [partial player name] [item id] <[value]> <[entry id]>", player, 230, 180, 95 )
				return
			else
				local targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )
				if ( not targetPlayer ) then
					outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95 )
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
								
								outputChatBox( "Took " .. getItemName( itemID ) .. " from " .. exports.common:getPlayerName(targetPlayer) .. ".", player, 95, 230, 95 )
							else
								outputChatBox( "That player doesn't have an item.", player, 230, 95, 95 )
							end
						else
							outputChatBox( "That player doesn't have item data initialized yet.", player, 230, 95, 95 )
						end
					else
						outputChatBox( "Invalid item ID.", player, 230, 95, 95 )
					end
				end
			end
		end
	end
)
]]