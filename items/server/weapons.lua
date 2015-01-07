function loadWeapons( player )
	takeAllWeapons( player )
	
	for weaponID, ammo in pairs( getPlayerAmmo( player ) ) do
		if ( type( ammo ) ~= "table" ) then
			giveWeapon( player, weaponID, ammo > 1 and ammo or 1 )
			
			if ( ammo > 1 ) then
				setWeaponAmmo( player, weaponID, ammo - 1 )
			end
		else
			giveWeapon( player, weaponID, 1 )
		end
	end
end

function getPlayerWeapons( player )
	local playerWeapons = { }
	
	for _, item in ipairs( getItems( player ) ) do
		if ( item.item_id == 11 ) then
			local weaponID = getWeaponID( item.value )
			
			if ( weaponID ) then
				playerWeapons[ weaponID ] = { db_id = item.db_id, value = item.value }
			end
		end
	end
	
	return playerWeapons
end

function getPlayerAmmo( player )
	local playerWeapons = getPlayerWeapons( player )
	
	for _, item in ipairs( getItems( player ) ) do
		if ( item.item_id == 12 ) then
			local ammoData = getItemSubValue( item.value )
			
			if ( ammoData ) then
				local weaponID = ammoData[ 1 ]
				local ammoAmount = ammoData[ 2 ]
				
				if ( weaponID ) and ( ammoAmount ) and ( playerWeapons[ weaponID ] ) then
					playerWeapons[ weaponID ] = ( type( playerWeapons[ weaponID ] ) == "number" and playerWeapons[ weaponID ] or 1 ) + ammoAmount
				end
			end
		end
	end
	
	return playerWeapons
end

local itemSaveTimer = { }

addEvent( "weapons:fire", true )
addEventHandler( "weapons:fire", root,
	function( clientWeaponID )
		if ( source ~= client ) or ( exports.admin:isServerInMaintenance( ) ) or ( exports.admin:isServerOverloaded( ) ) then
			return
		end
		
		for itemIndex, item in pairs( getItems( client ) ) do
			if ( item.item_id == 12 ) then
				local ammoData = getItemSubValue( item.value )
				
				if ( ammoData ) then
					local weaponID = ammoData[ 1 ]
					local ammoAmount = ammoData[ 2 ]
					
					if ( weaponID ) and ( ammoAmount ) and ( tonumber( weaponID ) == tonumber( clientWeaponID ) ) then
						data[ client ].items[ itemIndex ].value = weaponID .. ";" .. ammoAmount - 1
						
						if ( isTimer( itemSaveTimer[ client ] ) ) then
							killTimer( itemSaveTimer[ client ] )
						end
						
						itemSaveTimer[ client ] = setTimer( function( value, id )
							exports.database:execute( "UPDATE `inventory` SET `value` = ? WHERE `id` = ?", value, id )
						end, 15000, 1, data[ client ].items[ itemIndex ].value, item.db_id )
						
						--triggerClientEvent( client, "inventory:synchronize", client, getItems( client ) )
					end
				end
			end
		end
	end
)