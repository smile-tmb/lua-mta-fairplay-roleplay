addEvent( "items:act", true )
addEventHandler( "items:act", root,
	function( dbID, itemID, value )
		if ( source ~= client ) then
			return
		end
		
		local itemName = getItemName( itemID )
		local itemValue = getItemValue( itemID )
		
		if ( itemID == 1 ) then
			setElementHealth( client, math.min( 100, getElementHealth( client ) + itemValue ) )
			exports.chat:outputLocalActionMe( client, "moves a donut up to their mouth and eats a bite of it." )
			takeItem( client, itemID, value, dbID )
		elseif ( itemID == 2 ) then
			exports.chat:outputLocalActionMe( client, "throws a dice and it reveals number " .. math.random( 1, 6 ) .. "." )
		elseif ( itemID == 3 ) then
			setElementHealth( client, math.min( 100, getElementHealth( client ) + itemValue ) )
			exports.chat:outputLocalActionMe( client, "moves a water bottle up to their mouth, taking a sip of water." )
			takeItem( client, itemID, value, dbID )
		elseif ( itemID == 4 ) then
			setElementHealth( client, math.min( 100, getElementHealth( client ) + itemValue ) )
			exports.chat:outputLocalActionMe( client, "moves a coffee mug up to their mouth, taking a sip of coffee." )
			takeItem( client, itemID, value, dbID )
		elseif ( itemID == 10 ) then
			--triggerEvent( ":_displayPhone_:", client, value )
			exports.chat:outputLocalActionMe( client, "takes out a cellphone." )
		elseif ( itemID == 11 ) then
			local weaponID = getWeaponID( value )
			
			if ( weaponID ) then
				exports.chat:outputLocalActionMe( client, "equips a " .. getWeaponName( value ) .. "." )
				
				setPedWeaponSlot( client, getSlotFromWeapon( weaponID ) )
			end
		elseif ( itemID == 13 ) then
			outputChatBox( "You can use this radio by typing /r <message>", client, 230, 180, 95, false )
		elseif ( itemID == 14 ) then
			outputChatBox( "You can use this megaphone by typing /m <message>", client, 230, 180, 95, false )
		else
			exports.chat:outputLocalActionMe( client, "shows their " .. itemName .. " to everyone." )
		end
	end
)

addEvent( "items:delete", true )
addEventHandler( "items:delete", root,
	function( dbID, itemID, value )
		if ( source ~= client ) then
			return
		end
		
		local itemName = getItemName( itemID )
		local itemValue = getItemValue( itemID )
		
		exports.chat:outputLocalActionMe( client, "destroyed a " .. itemName .. "." )
		takeItem( client, itemID, value, dbID )
		
		if ( itemID == 10 ) then
			--triggerClientEvent( client, ":_exitPhoneWindows_:", client, value )
		end
	end
)