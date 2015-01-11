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

local worldItems = { }

addEvent( "items:drop", true )
addEventHandler( "items:drop", root,
	function( clientItem, x, y, z, element )
		if ( source ~= client ) then
			return
		end
		
		local hasItem, _, item = hasItem( client, clientItem.itemID, clientItem.itemValue, clientItem.id )
		
		if ( clientItem ) and ( hasItem ) then
			local rx, ry, rz = 0, 0, getPedRotation( client )
			
			if ( not isElement( element ) ) or ( isElement( element ) and getElementType( element ) ~= "player" ) or ( not exports.common:isPlayerPlaying( element ) ) then
				local offsetX, offsetY, offsetZ, offsetRotX, offsetRotY, offsetRotZ = getItemOffset( item.itemID ) 
				local x, y, z = x + offsetX, y + offsetY, z + offsetZ
				local rx, ry, rz = rx + offsetRotX, ry + offsetRotY, rz + offsetRotZ
				local interior, dimension = getElementInterior( client ), getElementDimension( client )
				local id = exports.database:insert_id( "INSERT INTO `worlditems` (`item_id`, `item_value`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `interior`, `dimension`, `user_id`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", item.itemID, item.itemValue, x, y, z, rx, ry, rz, interior, dimension, exports.common:getCharacterID( client ) )
				
				if ( id ) then
					local object = createObject( getItemModel( item.itemID ), x, y, z, rx, ry, rz )
					
					if ( object ) then
						setElementInterior( object, interior )
						setElementDimension( object, dimension )
						setElementAlpha( object, getItemAlpha( item.itemID ) )
						setElementCollisionsEnabled( object, isItemCollisionsEnabled( item.itemID ) )
						
						local values = exports.common:getSplitValues( item.itemValue )
						local ringtoneID, messagetoneID = values[ 2 ] or false, values[ 3 ] or false
						
						worldItems[ id ] = { itemID = item.itemID, itemValue = item.itemValue, userID = exports.common:getCharacterID( client ), posX = x, posY = y, posZ = z, rotX = rx, rotY = ry, rotZ = rz, object = object, ringtoneID = ringtoneID, messagetoneID = messagetoneID }
						
						exports.security:modifyElementData( object, "worlditem:id", id, true )
						exports.security:modifyElementData( object, "worlditem:item_id", item.itemID, true )
						exports.security:modifyElementData( object, "worlditem:value", item.itemValue, true )
						exports.security:modifyElementData( object, "worlditem:ringtone_id", ringtoneID, true )
						exports.security:modifyElementData( object, "worlditem:messagetone_id", messagetoneID, true )
						
						exports.chat:outputLocalActionMe( client, "dropped down a " .. getItemName( item.itemID ) .. "." )
						
						if ( item.itemID == 10 ) then
							--triggerClientEvent( client, ":_exitPhoneWindows_:", client, item.itemValue )
						end
						
						if ( not takeItem( client, item.id ) ) then
							outputChatBox( "Something is wrong (0xFE0000).", client, 230, 95, 95, false )
							table.remove( worldItems, id )
							destroyElement( object )
							exports.database:execute( "DELETE FROM `worlditems` WHERE `id` = ?", id )
						end
					else
						outputChatBox( "Something is wrong (0xEF0000).", client, 230, 95, 95, false )
					end
				else
					outputChatBox( "Something is wrong (0xFF0000).", client, 230, 95, 95, false )
				end
			else
				exports.chat:outputLocalActionMe( client, "gave " .. exports.common:getPlayerName( element ) .. " a " .. getItemName( item.itemID ) .. "." )
				takeItem( client, item.id )
				giveItem( element, item.itemID, value )
			end
		else
			outputChatBox( "You do not have such item.", client, 230, 95, 95, false )
		end
	end
)

addEvent( "items:pickup", true )
addEventHandler( "items:pickup", root,
	function( object )
		if ( source ~= client ) then
			return
		end
		
		local id = exports.common:getRealWorldItemID( object )
		
		if ( not isElement( object ) ) or ( not worldItems[ id ] ) then
			outputChatBox( "Oh, that item is no longer.", client, 230, 95, 95, false )
			return
		end
		
		local item = worldItems[ id ]
		
		exports.chat:outputLocalActionMe( client, "picked up a " .. getItemName( item.itemID ) .. "." )
		
		exports.database:execute( "DELETE FROM `worlditems` WHERE `id` = ?", id )
		
		if ( isElement( object ) ) then
			destroyElement( object )
		end
		
		giveItem( client, item.itemID, item.itemValue )
		
		table.remove( worldItems, id )
	end
)

addEvent( "items:update_position", true )
addEventHandler( "items:update_position", root,
	function( object, x, y, z )
		if ( source ~= client ) then
			return
		end
		
		local id = exports.common:getRealWorldItemID( object )
		
		if ( not isElement( object ) ) or ( not worldItems[ id ] ) then
			outputChatBox( "Oh, that item is no longer.", client, 230, 95, 95, false )
			return
		end
		
		exports.chat:outputLocalActionMe( client, "moved a " .. getItemName( worldItems[ id ].itemID ) .. "." )
		
		exports.database:execute( "UPDATE `worlditems` SET `pos_x` = ?, `pos_y` = ?, `pos_z` = ? WHERE `id` = ?", x, y, z, id )
		
		setElementPosition( object, x, y, z )
	end
)

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		local query = exports.database:query( "SELECT * FROM `worlditems`" )
		
		if ( query ) then
			if ( #query == 1 ) then
				outputDebugString( "1 world item is about to be loaded." )
			else
				outputDebugString( #query .. " world items are about to be loaded." )
			end
			
			for _, row in pairs( query ) do
				local item = getItem( row.item_id )
				
				if ( item ) then
					local offsetX, offsetY, offsetZ, offsetRotX, offsetRotY, offsetRotZ = getItemOffset( row.item_id )
					local x, y, z = row.pos_x + offsetX, row.pos_y + offsetY, row.pos_z + offsetZ
					local rx, ry, rz = row.rot_x + offsetRotX, row.rot_y + offsetRotY, row.rot_z + offsetRotZ
					
					local object = createObject( getItemModel( row.item_id ), x, y, z, rx, ry, rz )
					
					if ( object ) then
						setElementInterior( object, row.interior )
						setElementDimension( object, row.dimension )
						setElementAlpha( object, getItemAlpha( row.item_id ) )
						setElementCollisionsEnabled( object, isItemCollisionsEnabled( row.item_id ) )
						
						local values = exports.common:getSplitValues( row.item_value )
						local ringtoneID, messagetoneID = values[ 2 ] or false, values[ 3 ] or false
						
						worldItems[ row.id ] = { itemID = row.item_id, itemValue = row.item_value, userID = row.user_id, posX = x, posY = y, posZ = z, rotX = rx, rotY = ry, rotZ = rz, object = object, ringtoneID = ringtoneID, messagetoneID = messagetoneID }
						
						exports.security:modifyElementData( object, "worlditem:id", row.id, true )
						exports.security:modifyElementData( object, "worlditem:item_id", row.item_id, true )
						exports.security:modifyElementData( object, "worlditem:value", row.item_value, true )
						exports.security:modifyElementData( object, "worlditem:ringtone_id", ringtoneID, true )
						exports.security:modifyElementData( object, "worlditem:messagetone_id", messagetoneID, true )
					end
				end
			end
		else
			outputDebugString( "World item select query returned something weird => (" .. tostring( query ) .. ")[" .. type( query ) .. "]" )
		end
	end
)