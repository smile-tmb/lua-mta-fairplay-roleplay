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
	function( clientItem )
		if ( source ~= client ) or ( not exports.common:isPlayerPlaying( client ) ) then
			return
		end
		
		local hasItem, _, item = hasItem( client, clientItem.itemID, clientItem.itemValue, clientItem.id )
		
		if ( clientItem ) and ( hasItem ) then
			local itemName = getItemName( item.itemID )
			local itemValue = item.itemValue
			local id = item.id
			
			if ( item.itemID == 1 ) then
				if ( takeItem( client, id ) ) then
					setElementHealth( client, math.min( 100, getElementHealth( client ) + itemValue ) )
					exports.chat:outputLocalActionMe( client, "moves a donut up to their mouth and eats a bite of it." )
				end
			elseif ( item.itemID == 2 ) then
				exports.chat:outputLocalActionMe( client, "throws a dice and it reveals number " .. math.random( 1, 6 ) .. "." )
			elseif ( item.itemID == 3 ) then
				if ( takeItem( client, id ) ) then
					setElementHealth( client, math.min( 100, getElementHealth( client ) + itemValue ) )
					exports.chat:outputLocalActionMe( client, "moves a water bottle up to their mouth, taking a sip of water." )
				end
			elseif ( item.itemID == 4 ) then
				if ( takeItem( client, id ) ) then
					setElementHealth( client, math.min( 100, getElementHealth( client ) + itemValue ) )
					exports.chat:outputLocalActionMe( client, "moves a coffee mug up to their mouth, taking a sip of coffee." )
				end
			elseif ( item.itemID == 10 ) then
				--triggerEvent( ":_displayPhone_:", client, item.value )
				exports.chat:outputLocalActionMe( client, "takes out a cellphone." )
			elseif ( item.itemID == 11 ) then
				local weaponID = getWeaponID( itemValue )
				
				if ( weaponID ) then
					exports.chat:outputLocalActionMe( client, "equips a " .. getWeaponName( itemValue ) .. "." )
					
					setPedWeaponSlot( client, getSlotFromWeapon( weaponID ) )
				end
			elseif ( item.itemID == 13 ) then
				outputChatBox( "You can use this radio by typing /r <message>", client, 230, 180, 95 )
			elseif ( item.itemID == 14 ) then
				outputChatBox( "You can use this megaphone by typing /m <message>", client, 230, 180, 95 )
			else
				exports.chat:outputLocalActionMe( client, "shows their " .. itemName .. " to everyone." )
			end
		else
			outputChatBox( "You do not have such item.", client, 230, 95, 95 )
		end
	end
)

addEvent( "items:show", true )
addEventHandler( "items:show", root,
	function( clientItem )
		if ( source ~= client ) or ( not exports.common:isPlayerPlaying( client ) ) then
			return
		end
		
		local hasItem, _, item = hasItem( client, clientItem.itemID, clientItem.itemValue, clientItem.id )
		
		if ( clientItem ) and ( hasItem ) then
			exports.chat:outputLocalActionMe( client, "shows their " .. ( item.itemID == 11 and getWeaponName( itemValue ) or getItemName( item.itemID ) ) .. " to everyone." )
		else
			outputChatBox( "You do not have such item.", client, 230, 95, 95 )
		end
	end
)

addEvent( "items:delete", true )
addEventHandler( "items:delete", root,
	function( clientItem )
		if ( source ~= client ) or ( not exports.common:isPlayerPlaying( client ) ) then
			return
		end
		
		local hasItem, _, item = hasItem( client, clientItem.itemID, clientItem.itemValue, clientItem.id )
		
		if ( clientItem ) and ( hasItem ) then
			exports.chat:outputLocalActionMe( client, "destroyed a " .. getItemName( item.itemID ) .. "." )
			
			takeItem( client, item.id )
			
			if ( itemID == 10 ) then
				--triggerClientEvent( client, ":_exitPhoneWindows_:", client, value )
			end
		else
			outputChatBox( "You do not have such item.", client, 230, 95, 95 )
		end
	end
)