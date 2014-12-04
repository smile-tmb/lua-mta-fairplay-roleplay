local worldItems = { }

addEvent( "items:drop", true )
addEventHandler( "items:drop", root,
	function( element, dbID, itemID, value, ringtoneID, messagetoneID, x, y, z )
		if ( source ~= client ) then
			return
		end
		
		if ( not hasItem( client, itemID, value ) ) then
			outputChatBox( "Oh, you do not own that item any longer.", client, 230, 95, 95, false )
			return
		end
		
		local rx, ry, rz = getElementRotation( client )
		local item = getItems( )[ itemID ]
		
		if ( not element ) or ( element and getElementType( element ) ~= "player" ) or ( not exports.common:isPlayerPlaying( element ) ) then
			local x, y, z = x + item.offsetX, y + item.offsetY, z + item.offsetZ
			local rx, ry, rz = rx + item.offsetRX, ry + item.offsetRY, rz + item.offsetRZ
			local interior = getElementInterior( client )
			local dimension = getElementDimension( client )
			
			local object = createObject( item.model, x, y, z, rx, ry, rz )
			
			setElementInterior( object, interior )
			setElementDimension( object, dimension )
			setElementAlpha( object, item.alpha )
			setElementCollisionsEnabled( object, item.collisions )
			
			local lastid = exports.database:insert_id( "INSERT INTO `worlditems` (`item_id`, `value`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `interior`, `dimension`, `ringtone_id`, `messagetone_id`, `user_id`, `created_time`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())", itemID, value, x, y, z, rx, ry, rz, interior, dimension, ringtoneID, messagetoneID, exports.common:getCharacterID( client ) )
			
			worldItems[ lastid ] = { item_id = itemID, value = value, user_id = exports.common:getCharacterID( client ), pos_x = x, pos_y = y, pos_z = z, rot_x = rx, rot_y = ry, rot_z = rz, object = object, ringtone_id = 0, messagetone_id = 0 }
			
			exports.security:modifyElementData( object, "worlditem:id", lastid, true )
			exports.security:modifyElementData( object, "worlditem:item_id", itemID, true )
			exports.security:modifyElementData( object, "worlditem:value", value, true )
			exports.security:modifyElementData( object, "worlditem:ringtone_id", ringtoneID, true )
			exports.security:modifyElementData( object, "worlditem:messagetone_id", messagetoneID, true )
			
			exports.chat:outputLocalActionMe( client, "dropped down a " .. item.name .. "." )
			takeItem( client, itemID, value, dbID )
			
			if ( itemID == 10 ) then
				--triggerClientEvent(client, ":_exitPhoneWindows_:", client, value)
			end
		else
			exports.chat:outputLocalActionMe( client, "gave " .. exports.common:getRealPlayerName( element ) .. " a " .. item.name .. "." )
			takeItem( client, itemID, value, dbID )
			giveItem( element, itemID, value )
		end
	end
)

addEvent( "items:pickup", true )
addEventHandler( "items:pickup", root,
	function( tableID, object )
		if ( source ~= client ) then
			return
		end
		
		if ( not worldItems[ tableID ] ) or ( not isElement( object ) ) then
			outputChatBox( "Oh, that item is no longer.", client, 230, 95, 95, false )
			return
		end
		
		local item = getItems( )[ worldItems[ tableID ].item_id ]
		
		exports.chat:outputLocalActionMe( client, "picked up a " .. item.name .. "." )
		
		exports.database:execute( "DELETE FROM `worlditems` WHERE `id` = ?", tableID )
		
		if ( isElement( object ) ) then
			destroyElement( object )
		end
		
		giveItem( client, worldItems[ tableID ].item_id, worldItems[ tableID ].value )
		table.remove( worlditems, tableID )
	end
)

addEvent( "items:updateposition", true )
addEventHandler( "items:updateposition", root,
	function( tableID, object, x, y, z )
		if ( source ~= client ) then
			return
		end
		
		if ( not isElement( object ) ) then
			outputChatBox( "Oh, that item is no longer.", client, 230, 95, 95, false )
			return
		end
		
		local item = getItems( )[ worldItems[ tableID ].item_id ]
		
		exports.chat:outputLocalActionMe( client, "moved a " .. item.name .. "." )
		
		exports.database:execute( "UPDATE `worlditems` SET `pos_x` = ?, `pos_y` = ?, `pos_z` = ? WHERE `id` = ?", x, y, z, tableID )
		
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
				local item = getItems( )[ row.item_id ]
				
				if ( item ) then
					local x, y, z = row.pos_x + item.offsetX, row.pos_y + item.offsetY, row.pos_z + item.offsetZ
					local rx, ry, rz = row.rot_x + item.offsetRX, row.rot_y + item.offsetRY, row.rot_z + item.offsetRZ
					
					local object = createObject( item.model, x, y, z, rx, ry, rz )
					
					setElementInterior( object, row.interior )
					setElementDimension( object, row.dimension )
					setElementAlpha( object, getItems( )[ row.item_id ].alpha )
					setElementCollisionsEnabled( object, item.collisions )
					
					worldItems[ row.id ] = { item_id = row.item_id, value = row.value, user_id = row.user_id, pos_x = x, pos_y = y, pos_z = z, rot_x = rx, rot_y = ry, rot_z = rz, object = object, ringtone_id = row.ringtone_id, messagetone_id = row.messagetone_id }
					
					exports.security:modifyElementData( object, "worlditem:id", row.id, true )
					exports.security:modifyElementData( object, "worlditem:item_id", row.item_id, true )
					exports.security:modifyElementData( object, "worlditem:value", row.value, true )
					exports.security:modifyElementData( object, "worlditem:ringtone_id", row.ringtone_id, true )
					exports.security:modifyElementData( object, "worlditem:messagetone_id", row.messagetone_id, true )
				end
			end
		else
			outputDebugString( "0 world items loaded. Does the world items table contain data and are the settings correct?" )
		end
	end
)