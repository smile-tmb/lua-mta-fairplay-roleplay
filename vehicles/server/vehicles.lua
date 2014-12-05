local _get = get

function get( id )
	return exports.database:query_single( "SELECT * FROM `vehicles` WHERE `id` = ?", id )
end

function new( modelID, posX, posY, posZ, rotX, rotY, rotZ, interior, dimension, variantA, variantB, ownerID, faction, color, isLocked, isBulletproof )
	rotX, rotY, rotZ = rotX or 0, rotY or 0, rotZ or 0
	interior, dimension = interior or 0, dimension or 0
	variantA, variantB = variantA or 255, variantB or 255
	ownerID = ownerID or 0
	color = color or defaultColor
	isLocked = isLocked or true
	engineOn = engineOn or false
	isBulletproof = isBulletproof or false
	
	local numberplate = getNumberPlate( )
	
	if ( vehicle ) then
		local vehicleID = exports.database:insert_id( "INSERT INTO `vehicles` (`model_id`, `pos_x`, `pos_y`, `pos_z`, `rot_x`, `rot_y`, `rot_z`, `interior`, `dimension`, `numberplate`, `variant_1`, `variant_2`, `owner_id`, `color`, `is_locked`, `is_bulletproof`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", modelID, posX, posY, posZ, rotX, rotY, rotZ, interior, dimension, numberplate, variantA, variantB, ownerID, color, isLocked, isBulletproof )
		
		return spawn( vehicleID )
	end
	
	return false
end

function spawn( vehicleID )
	local data = get( vehicleID )
	
	if ( data ) then
		local vehicle = createVehicle( data.model_id, data.pos_x, data.pos_y, data.pos_z, data.rot_x, data.rot_y, data.rot_z, data.numberplate, false, data.variant_1, variant_2 )
		
		if ( vehicle ) then
			setElementInterior( vehicle, data.interior )
			setElementDimension( vehicle, data.dimension )
			setElementHealth( vehicle, data.health )
			
			setVehicleLocked( vehicle, data.is_locked )
			setVehicleDoorsUndamageable( vehicle, data.is_bulletproof )
			setVehicleDamageProof( vehicle, data.is_bulletproof )
			setVehicleOverrideLights( vehicle, data.headlight_state )
			setVehicleEngineState( vehicle, data.is_engine_on )
			setVehicleRespawnPosition( vehicle, data.respawn_x, data.respawn_y, data.respawn_z, data.respawn_rx, data.respawn_ry, data.respawn_rz )
			toggleVehicleRespawn( vehicle, false )
			
			setElementData( vehicle, "vehicle:id", data.id, true )
			setElementData( vehicle, "vehicle:owner_id", math.abs( data.owner_id ), true )
			setElementData( vehicle, "vehicle:faction", data.owner_id < 0, true )
			setElementData( vehicle, "vehicle:civilian", data.owner_id == 0, true )
			
			local panels = fromJSON( data.panel_states ) --setVehiclePanelState
			local doors = fromJSON( data.door_states ) --setVehicleDoorState
			
			return vehicle
		end
	end
	
	return false
end