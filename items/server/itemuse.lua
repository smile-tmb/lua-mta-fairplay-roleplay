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

addEvent( "items:use", true )
addEventHandler( "items:use", root,
	function( id )
		if ( source ~= client ) then
			return
		end
		
		local item = nil
		
		for _, values in pairs( getItems( client ) ) do
			if ( values.id == id ) then
				item = values
				break
			end
		end
		
		local itemName = getItemName( item.itemID )
		local itemValue = getItemValue( item.itemID )
		
		if ( item.itemID == 1 ) then
			setElementHealth( client, math.min( 100, getElementHealth( client ) + itemValue ) )
			exports.chat:outputLocalActionMe( client, "moves a donut up to their mouth and eats a bite of it." )
			takeItem( client, id )
		elseif ( item.itemID == 2 ) then
			exports.chat:outputLocalActionMe( client, "throws a dice and it reveals number " .. math.random( 1, 6 ) .. "." )
		elseif ( item.itemID == 3 ) then
			setElementHealth( client, math.min( 100, getElementHealth( client ) + itemValue ) )
			exports.chat:outputLocalActionMe( client, "moves a water bottle up to their mouth, taking a sip of water." )
			takeItem( client, id )
		elseif ( item.itemID == 4 ) then
			setElementHealth( client, math.min( 100, getElementHealth( client ) + itemValue ) )
			exports.chat:outputLocalActionMe( client, "moves a coffee mug up to their mouth, taking a sip of coffee." )
			takeItem( client, id )
		elseif ( item.itemID == 10 ) then
			--triggerEvent( ":_displayPhone_:", client, item.value )
			exports.chat:outputLocalActionMe( client, "takes out a cellphone." )
		elseif ( item.itemID == 11 ) then
			local weaponID = getWeaponID( item.value )
			
			if ( weaponID ) then
				exports.chat:outputLocalActionMe( client, "equips a " .. getWeaponName( item.value ) .. "." )
				
				setPedWeaponSlot( client, getSlotFromWeapon( weaponID ) )
			end
		elseif ( item.itemID == 13 ) then
			outputChatBox( "You can use this radio by typing /r <message>", client, 230, 180, 95, false )
		elseif ( item.itemID == 14 ) then
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