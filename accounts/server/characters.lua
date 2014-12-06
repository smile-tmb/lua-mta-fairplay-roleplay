local defaultSpawnX, defaultSpawnY, defaultSpawnZ = 1731.03, -1912.05, 13.56
local defaultSpawnRotation = 90
local defaultSpawnInterior, defaultSpawnDimension = 0, 0

function getCharacter( id )
	return exports.database:query_single( "SELECT * FROM `characters` WHERE `id` = ?", id )
end

function getCharacterByName( name, null )
	return exports.database:query_single( "SELECT " .. ( null and "NULL" or "*" ) .. " FROM `characters` WHERE `name` = ?", name )
end

function verifyCharacterName( name )
	name = name:gsub( "%c%d\!\?\=\)\(\\\/\"\#\&\%\[\]\{\}\*\^\~\:\;\>\<", "" ):gsub( "_", " " )
	local nameParts = split( name, " " )
	
	outputChatBox( #nameParts )
	
	if ( #nameParts >= 2 ) then
		for i, v in ipairs( nameParts ) do
			if ( v:len( ) > 1 ) then
				local firstLetter = v:sub( 1, 1 )
				
				if ( firstLetter < 'A' ) or ( firstLetter > 'Z' ) then
					return -3, i
				end
			else
				return -2, i
			end
		end
		
		if ( name:len( ) >= minimumNameLength ) then
			if ( name:len( ) <= maximumNameLength ) then
				return true
			else
				return -5
			end
		else
			return -4
		end
	else
		return -1
	end
end

addEvent( "characters:create", true )
addEventHandler( "characters:create", root,
	function( characterSkinModel, characterName, characterDateOfBirth, characterGender, characterSkinColor, characterOrigin, characterLook )
		if ( source ~= client ) then
			return
		end
		
		if ( characterName ) and ( characterDateOfBirth ) and ( characterGender ) and ( characterSkinColor ) and ( characterOrigin ) and ( characterLook ) then
			local verified, namePart = verifyCharacterName( characterName )
			
			if ( verified == true ) then
				characterName = characterName:gsub( "%s", "_" )
				
				if ( not getCharacterByName( characterName ) ) then
					local characterID = exports.database:insert_id( "INSERT INTO `characters` (`account`, `skin_id`, `name`, `pos_x`, `pos_y`, `pos_z`, `rotation`, `interior`, `dimension`, `date_of_birth`, `gender`, `skin_color`, `origin`, `look`, `created_time`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", exports.common:getAccountID( client ), characterSkinModel, characterName, defaultSpawnX, defaultSpawnY, defaultSpawnZ, defaultSpawnRotation, defaultSpawnInterior, defaultSpawnDimension, characterDateOfBirth, characterGender, characterSkinColor, characterOrigin, characterLook, "NOW()" )
					
					if ( characterID ) then
						exports.messages:destroyMessage( client, "selection" )
						
						triggerClientEvent( client, "characters:closeGUI", client )
						
						spawnCharacter( client, characterID, true )
					else
						triggerClientEvent( client, "messages:create", client, "Oops, something went wrong. Please try again.", "selection" )
					end
				else
					triggerClientEvent( client, "messages:create", client, "A character with this name already exists. Please try another name.", "selection" )
				end
			else
				if ( verified == -1 ) then
					triggerClientEvent( client, "messages:create", client, "Please enter your first and lastname (e.g. John Doe).", "selection" )
				elseif ( verified == -2 ) then
					local part = namePart == 1 and "firstname" or "lastname"
					triggerClientEvent( client, "messages:create", client, "Please enter a longer " .. part .. ".", "selection" )
				elseif ( verified == -3 ) then
					local part = namePart == 1 and "firstname" or "lastname"
					triggerClientEvent( client, "messages:create", client, "Please enter your " .. part .. " with the starting letter in capital.", "selection" )
				elseif ( verified == -4 ) then
					triggerClientEvent( client, "messages:create", client, "Character name must be at least " .. minimumNameLength .. " characters long.", "selection" )
				elseif ( verified == -5 ) then
					triggerClientEvent( client, "messages:create", client, "Character name must be at most " .. maximumNameLength .. " characters long.", "selection" )
				end
			end
		else
			triggerClientEvent( client, "messages:create", client, "Oops, something went wrong. Please try again.", "selection" )
		end
	end
)

addEvent( "characters:play", true )
addEventHandler( "characters:play", root,
	function( characterName )
		if ( source ~= client ) then
			return
		end
		
		exports.messages:destroyMessage( client, "selection" )
		
		local accountID = tonumber( getElementData( client, "database:id" ) )
		
		if ( not accountID ) then
			triggerClientEvent( client, "accounts:showLogin", client )
		else
			characterName = characterName:gsub( " ", "_" )
			local character = exports.database:query_single( "SELECT * FROM `characters` WHERE `name` = ? AND `account` = ?", characterName, accountID )
			
			if ( character ) then
				triggerClientEvent( client, "characters:closeGUI", client )
				spawnCharacter( client, character, true )
			else
				exports.messages:createMessage( client, "Unable to retrieve information for this character. Please try again.", "selection" )
			end
		end
	end
)

function saveCharacter( player )
	if ( exports.common:isPlayerPlaying( player ) ) then
		local x, y, z = getElementPosition( player )
		local rotation = getPedRotation( player )
		local interior = getElementInterior( player )
		local dimension = getElementDimension( player )
		local skinModel = getElementModel( player )
		local characterID = exports.common:getCharacterID( player )
		
		return exports.database:execute( "UPDATE `characters` SET `pos_x` = ?, `pos_y` = ?, `pos_z` = ?, `rotation` = ?, `interior` = ?, `dimension` = ?, `skin_id` = ?, `last_played` = NOW() WHERE `id` = ?", x, y, z, rotation, interior, dimension, skinModel, characterID )
	end
end

addCommandHandler( "saveme",
	function( player )
		if ( saveCharacter( player ) ) then
			outputChatBox( "Your character has been successfully saved.", player, 95, 230, 95, false )
		end
	end
)

addEventHandler( "onResourceStop", resourceRoot,
	function( )
		for _, player in ipairs( getElementsByType( "player" ) ) do
			saveCharacter( player )
		end
	end
)

addEventHandler( "onPlayerQuit", root,
	function( )
		saveCharacter( source )
	end
)

function characterSelection( player )
	saveCharacter( player )
	
	removeElementData( player, "player:playing" )
	
	removeElementData( player, "character:id" )
	removeElementData( player, "character:name" )
	removeElementData( player, "character:gender" )
	removeElementData( player, "character:skin_color" )
	removeElementData( player, "character:origin" )
	removeElementData( player, "character:look" )
	removeElementData( player, "character:date_of_birth" )
	removeElementData( player, "character:weight" )
	removeElementData( player, "character:max_weight" )
	
	triggerClientEvent( player, "superman:stop", player )
	
	spawnPlayer( player, 0, 0, 0 )
	setElementDimension( player, 6000 )
	
	setCameraMatrix( player, 0, 0, 100, 100, 100, 100 )
	
	triggerClientEvent( player, "accounts:showCharacterSelection", player )
	triggerClientEvent( player, "messages:destroy", player, "selection" )
	
	updateCharacters( player )
end

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
				
				spawnPlayer( player, character.pos_x, character.pos_y, character.pos_z, character.rotation, character.skin_id, character.interior, character.dimension, getTeamFromName( "Civilian" ) or nil )
				setPedRotation( player, character.rotation )
				setPlayerName( player, character.name )
				
				exports.items:loadItems( player )
				
				triggerClientEvent( player, "characters:onSpawn", player )
				
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