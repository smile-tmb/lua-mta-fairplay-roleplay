function characterKill( characterID, causeOfDeath )
	local characterPlayer = exports.common:getPlayerByCharacterID( characterID )
	
	if ( characterPlayer ) then
		exports.accounts:saveCharacter( characterPlayer )
	end
	
	local character = exports.accounts:getCharacter( characterID )
	
	if ( character ) and ( character.is_dead == 0 ) then
		exports.database:execute( "UPDATE `characters` SET `is_dead` = '1', `cause_of_death` = ? WHERE `id` = ?", causeOfDeath, characterID )
		
		local ped = createPed( character.skin_id, character.pos_x, character.pos_y, character.pos_z, character.rotation, false )
		
		setElementInterior( ped, character.interior )
		setElementDimension( ped, character.dimension )
		
		killPed( ped )
		
		exports.security:modifyElementData( ped, "npc:character_kill.id", character.id, true )
		exports.security:modifyElementData( ped, "npc:character_kill.reason", causeOfDeath, true )
		
		local player = exports.common:getPlayerByAccountID( character.account )
		
		if ( player ) then
			if ( characterPlayer ) then
				exports.accounts:characterSelection( player )
				
				outputChatBox( "You were character killed by an administrator.", player, 230, 180, 95, false )
				outputChatBox( " Cause of death: " .. causeOfDeath, player, 230, 180, 95, false )
			else
				exports.accounts:updateCharacters( player )
			end
		end
		
		return true
	end
	
	return false
end

function characterResurrect( characterID )
	local character = exports.accounts:getCharacter( characterID )
	
	if ( character ) and ( character.is_dead ~= 0 ) then
		exports.database:execute( "UPDATE `characters` SET `is_dead` = '0', `cause_of_death` = '' WHERE `id` = ?", character.id )
		
		local ped = findCharacterKillPed( character.id )
		
		if ( ped ) then
			destroyElement( ped )
		end
		
		local player = exports.common:getPlayerByAccountID( character.account )
		
		if ( player ) and ( not getElementData( player, "player:playing" ) ) then
			exports.accounts:updateCharacters( player )
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

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		loadCharacterKills( )
	end
)