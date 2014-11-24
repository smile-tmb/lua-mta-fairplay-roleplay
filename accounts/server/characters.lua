function getCharacter( id )
	return exports.database:query_single( "SELECT * FROM `characters` WHERE `id` = ?", id )
end

function newCharacter( name, accountID, modelID )
	return exports.database:insert_id( "INSERT INTO `characters` (`name`, `account`, `skin_id`) VALUES (?, ?, ?)", name, accountID, modelID )
end

addEvent( "accounts:play", true )
addEventHandler( "accounts:play", root,
	function( characterName )
		if ( source ~= client ) then
			return
		end
		
		exports.messages:destroyMessage( client, "selection" )
		
		local accountID = tonumber( getElementData( client, "database:id" ) )
		
		if ( not accountID ) then
			triggerClientEvent( client, "accounts:showLogin", client )
		else
			if ( characterName ) then
				local character = exports.database:query_single( "SELECT * FROM `characters` WHERE `name` = ? AND `account` = ?", characterName, accountID )
				
				if ( character ) then
					triggerClientEvent( client, "accounts:closeCharacterSelection", client )
					spawnCharacter( client, character, true )
				else
					exports.messages:createMessage( client, "Unable to retrieve information for this character. Please try again.", "selection" )
				end
			end
		end
	end
)

function spawnCharacter( player, character, fade )
	local character = type( character ) == "number" and getCharacter( character ) or ( type( character ) == "table" and character or nil )
	
	if ( character ) then
		function play( player, character )
			if ( isElement( player ) ) then
				exports.security:modifyElementData( player, "player:playing", true, true )
				
				exports.security:modifyElementData( player, "character:id", character.id, true )
				exports.security:modifyElementData( player, "character:name", character.name, true )
				exports.security:modifyElementData( player, "character:gender", character.gender, true )
				exports.security:modifyElementData( player, "character:skin_color", character.skin_color, true )
				exports.security:modifyElementData( player, "character:origin", character.origin, true )
				exports.security:modifyElementData( player, "character:look", character.look, true )
				exports.security:modifyElementData( player, "character:date_of_birth", character.date_of_birth, true )
				
				exports.database:query( "UPDATE `characters` SET `last_played` = NOW( ) WHERE `id` = ?", character.id )
				
				spawnPlayer( player, character.pos_x, character.pos_y, character.pos_z, character.rotation, character.skin_id, character.interior, character.dimension, getTeamFromName( "Civilian" ) )
				
				setCameraTarget( player, player )
				
				fadeCamera( player, true, 2.0 )
			end
		end
		
		if ( fade ) then
			fadeCamera( player, false, 2.725 )
			setTimer( play, 2725, 1, player, character )
		else
			play( )
		end
	end
end

function updateCharacters( player )
	local accountID = tonumber( getElementData( player, "database:id" ) )
	
	if ( accountID ) then
		local characters = exports.database:query( "SELECT * FROM `characters` WHERE `account` = ?", accountID )
		
		if ( characters ) then
			triggerClientEvent( player, "accounts:addCharacters", player, characters )
		end
	end
end