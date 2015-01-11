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

function loadWeapons( player )
	takeAllWeapons( player )
	
	for weaponID, data in pairs( getPlayerAmmo( player ) ) do
		if ( data.ammoAmount ) then
			giveWeapon( player, weaponID, data.ammoAmount > 1 and data.ammoAmount or 1 )
			
			if ( data.ammoAmount > 1 ) then
				setWeaponAmmo( player, weaponID, data.ammoAmount - 1 )
			end
		else
			giveWeapon( player, weaponID, 1 )
		end
	end
end

function getPlayerWeapons( player )
	local result = { }
	
	for _, item in ipairs( getItems( player ) ) do
		if ( item.itemID == 11 ) then
			local weaponID = getWeaponID( item.itemValue )
			
			if ( weaponID ) then
				result[ weaponID ] = item
			end
		end
	end
	
	return result
end

function getPlayerAmmo( player )
	local result = getPlayerWeapons( player )
	
	for _, item in ipairs( getItems( player ) ) do
		if ( item.itemID == 12 ) then
			local ammoData = getItemSubValue( item.itemValue )
			
			if ( ammoData ) then
				local weaponID = ammoData[ 1 ]
				local ammoAmount = ammoData[ 2 ]
				
				if ( weaponID ) and ( ammoAmount ) and ( result[ weaponID ] ) then
					result[ weaponID ].ammoAmount = ( type( result[ weaponID ] ) == "number" and result[ weaponID ] or 1 ) + ammoAmount
				end
			end
		end
	end
	
	return result
end

local itemSaveTimer = { }

addEvent( "weapons:fire", true )
addEventHandler( "weapons:fire", root,
	function( clientWeaponID )
		if ( source ~= client ) or ( exports.admin:isServerInMaintenance( ) ) or ( exports.admin:isServerOverloaded( ) ) then
			return
		end
		
		for itemIndex, item in pairs( getItems( client ) ) do
			if ( item.itemID == 12 ) then
				local ammoData = getItemSubValue( item.itemValue )
				
				if ( ammoData ) then
					local weaponID = ammoData[ 1 ]
					local ammoAmount = ammoData[ 2 ]
					
					if ( weaponID ) and ( ammoAmount ) and ( tonumber( weaponID ) == tonumber( clientWeaponID ) ) then
						data[ client ].items[ itemIndex ].itemValue = weaponID .. ";" .. ammoAmount - 1
						
						if ( isTimer( itemSaveTimer[ client ] ) ) then
							killTimer( itemSaveTimer[ client ] )
						end
						
						itemSaveTimer[ client ] = setTimer( function( value, id )
							exports.database:execute( "UPDATE `inventory` SET `value` = ? WHERE `id` = ?", value, id )
						end, 15000, 1, data[ client ].items[ itemIndex ].itemValue, item.id )
						
						--triggerClientEvent( client, "inventory:synchronize", client, getItems( client ) )
					end
				end
			end
		end
	end
)