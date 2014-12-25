function characterKill( player, causeOfDeath )
	exports.database:execute( "UPDATE `characters` SET `is_dead` = '1', `cause_of_death` = ? WHERE `id` = ?", causeOfDeath, exports.common:getCharacterID( player ) )
	
	setElementAlpha( player, 0 )
	
	local ped = createPed( getElementModel( player ), getElementPosition( player ) )
	
	setElementRotation( ped, getElementRotation( player ) )
	setElementInterior( ped, getElementInterior( player ) )
	setElementDimension( ped, getElementDimension( player ) )
	
	killPed( ped )
	
	exports.security:modifyElementData( ped, "npc:character_kill.id", exports.common:getCharacterID( player ), true )
	exports.security:modifyElementData( ped, "npc:character_kill.reason", causeOfDeath, true )
	
	exports.accounts:characterSelection( player )
end

function characterResurrect( characterName )
	local character = exports.accounts:getCharacterByName( characterName )
	
	if ( character ) then
		exports.database:execute( "UPDATE `characters` SET `is_dead` = '0', `cause_of_death` = '' WHERE `id` = ?", character.id )
		
		local ped = findCharacterKillPed( character.id )
		
		if ( ped ) then
			destroyElement( ped )
		end
		
		return true
	end
	
	return false
end

function findCharacterKillPed( characterID )
	for _, ped in ipairs( getElementsByType( "ped", getResourceDynamicElementRoot( resource ) ) ) do
		if ( getElementData( ped, "npc:character_kill.id" ) ) and ( tonumber( getElementData( ped, "npc:character_kill.id" ) ) == characterID ) then
			return ped
		end
	end
	
	return false
end

function loadCharacterKills( )
	for _, ped in ipairs( getElementsByType( "ped", getResourceDynamicElementRoot( resource ) ) ) do
		if ( getElementData( ped, "npc:character_kill.id" ) ) and ( tonumber( getElementData( ped, "npc:character_kill.id" ) ) == characterID ) then
			destroyElement( ped )
		end
	end
	
	for _, data in ipairs( exports.database:query( "SELECT * FROM `characters` WHERE `is_dead` = '1'" ) ) do
		local ped = createPed( data.skin_id, data.pos_x, data.pos_y, data.pos_z )
		
		setPedRotation( ped, data.rotation )
		setElementInterior( ped, data.interior )
		setElementDimension( ped, data.dimension )
		
		killPed( ped )
		
		exports.security:modifyElementData( ped, "npc:character_kill.id", data.id, true )
		exports.security:modifyElementData( ped, "npc:character_kill.reason", data.cause_of_death, true )
	end
end