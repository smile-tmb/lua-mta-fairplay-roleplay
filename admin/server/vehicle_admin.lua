addCommandHandler( { "createvehicle", "newvehicle", "createveh", "makeveh", "makevehicle", "makecar", "createcar" },
	function( player, cmd, modelID, ownerID, faction, isBulletproof )
		if ( exports.common:isPlayerServerAdmin( player ) ) then
			if ( not modelID ) or ( not ownerID ) or ( not faction ) then
				outputChatBox( "SYNTAX: /" .. cmd .. " [model id] [owner id] [faction: 0/1] [bulletproof: 0/1]", player, 230, 180, 95, false )
				
				return
			end
			
			modelID = tonumber( modelID )
			
			if ( not exports.common:isValidVehicleModelID( modelID ) ) then
				outputChatBox( "This vehicle ID is not valid.", player, 230, 95, 95, false )
				
				return
			end
			
			ownerID = tonumber( ownerID )
			faction = tonumber( faction ) == 1
			
			if ( not faction ) then
				local targetCharacter = exports.accounts:getCharacter( ownerID )
				
				if ( not targetCharacter ) then
					outputChatBox( "No such character found.", player, 230, 95, 95, false )
					
					return
				end
			else
				local targetFaction = exports.factions:getFactionByID( ownerID )
				
				if ( not targetFaction ) then
					outputChatBox( "No such faction found.", player, 230, 95, 95, false )
					
					return
				else
					ownerID = exports.common:getFactionID( targetFaction )
				end
			end
			
			isBulletproof = tonumber( isBulletproof ) == 1
			
			local x, y, z = exports.common:nextToPosition( player )
			local rotation = getPedRotation( player )
			local interior, dimension = getElementInterior( player ), getElementDimension( player )
			
			local vehicleID, vehicle = exports.vehicles:new( modelID, x, y, z, nil, nil, rotation, interior, dimension, nil, nil, ownerID, faction, nil, nil, isBulletproof )
			
			if ( vehicleID ) then
				outputChatBox( "You created a " .. getVehicleNameFromModel( modelID ) .. " with ID " .. vehicleID .. ".", player, 95, 230, 95, false )
				
				if ( not vehicle ) then
					outputChatBox( "However, we were unable to spawn the vehicle, please try spawning it manually via /spawnvehicle.", player, 230, 95, 95, false )
				end
			else
				outputChatBox( "Could not create a " .. getVehicleNameFromModel( modelID ) .. ". Please try again.", player, 230, 95, 95, false )
			end
		end
	end
)