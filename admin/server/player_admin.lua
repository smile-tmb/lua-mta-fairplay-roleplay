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

addCommandHandler( "revive",
	function( player, cmd, targetPlayer, ... )
		if ( exports.common:isPlayerServerSeniorAdmin( player ) ) then
			if ( not targetPlayer ) then
				outputChatBox( "SYNTAX: /" .. cmd .. " [partial player name] <[injuries (respawn at hospital)]>", player, 230, 180, 95, false )
				
				return
			end
			
			targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )
			
			if ( not targetPlayer ) then
				outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95, false )
				
				return
			end
			
			if ( not isPedDead( targetPlayer ) ) then
				outputChatBox( "That player is not dead.", player, 230, 95, 95, false )
				
				return
			end
			
			exports.security:modifyElementData( targetPlayer, "player:waiting", nil, true )
			exports.messages:destroyMessage( targetPlayer, "wait-for-admin" )
			
			triggerClientEvent( targetPlayer, "realism:hide_death_scene", targetPlayer )
			
			local message = ... and table.concat( { ... }, " " ) or nil
			
			if ( not ... ) or ( message:len( ) == 0 ) then
				exports.realism:reviveCharacter( targetPlayer )
				
				outputChatBox( "You were revived by an administrator.", targetPlayer, 230, 180, 95, false )
				outputChatBox( "Revived " .. exports.common:getPlayerName( targetPlayer ) .. ".", player, 95, 230, 95, false )
			else
				exports.realism:respawnCharacter( targetPlayer, message )
				
				outputChatBox( "You were respawned at the hospital by an administrator.", targetPlayer, 230, 180, 95, false )
				outputChatBox( " Details related to respawn: " .. message, targetPlayer, 230, 180, 95, false )
				outputChatBox( "Respawned " .. exports.common:getPlayerName( targetPlayer ) .. " at the hospital.", player, 95, 230, 95, false )
			end
		end
	end
)

addCommandHandler( "ck",
	function( player, cmd, characterName, ... )
		if ( exports.common:isPlayerServerSeniorAdmin( player ) ) then
			local causeOfDeath = table.concat( { ... }, " " )
			
			if ( not characterName ) or ( not causeOfDeath ) or ( causeOfDeath:len( ) < 5 ) then
				outputChatBox( "SYNTAX: /" .. cmd .. " [full character name] [cause of death]", player, 230, 180, 95, false )
				
				return
			end
			
			local characterName = characterName:gsub( " ", "_" )
			local character = exports.accounts:getCharacterByName( characterName )
			
			if ( character ) then
				if ( exports.realism:characterKill( character.id, causeOfDeath ) ) then
					outputChatBox( "Character killed " .. character.name:gsub( "_", " " ) .. ".", player, 95, 230, 95, false )
				else
					outputChatBox( "Something went wrong when trying to kill that character. Is that character dead already?", player, 230, 95, 95, false )
				end
			else
				outputChatBox( "Could not find a character with that name.", player, 230, 95, 95, false )
			end
		end
	end
)

addCommandHandler( "unck",
	function( player, cmd, characterName )
		if ( exports.common:isPlayerServerSeniorAdmin( player ) ) then
			if ( not characterName ) then
				outputChatBox( "SYNTAX: /" .. cmd .. " [full character name]", player, 230, 180, 95, false )
				
				return
			end
			
			local characterName = characterName:gsub( " ", "_" )
			local character = exports.accounts:getCharacterByName( characterName )
			
			if ( character ) then
				if ( exports.realism:characterResurrect( character.id ) ) then
					outputChatBox( "Resurrected " .. character.name:gsub( "_", " " ) .. ".", player, 95, 230, 95, false )
				else
					outputChatBox( "Something went wrong when trying to resurrect that character. Is that character alive already?", player, 230, 95, 95, false )
				end
			else
				outputChatBox( "Could not find a character with that name.", player, 230, 95, 95, false )
			end
		end
	end
)

addCommandHandler( "bury",
	function( player, cmd, characterName )
		if ( exports.common:isPlayerServerSeniorAdmin( player ) ) then
			if ( not characterName ) then
				outputChatBox( "SYNTAX: /" .. cmd .. " [full character name]", player, 230, 180, 95, false )
				
				return
			end
			
			local characterName = characterName:gsub( " ", "_" )
			local character = exports.accounts:getCharacterByName( characterName )
			
			if ( character ) then
				if ( character.is_dead == 1 ) then
					if ( exports.database:execute( "UPDATE `characters` SET `is_dead` = '2' WHERE `id` = ? AND `is_dead` = '1'", character.id ) ) then
						outputChatBox( "Buried " .. character.name:gsub( "_", " " ) .. ".", player, 95, 230, 95, false )
					else
						outputChatBox( "Something went wrong when trying to bury that character, try again.", player, 230, 95, 95, false )
					end
				elseif ( character.is_dead == 2 ) then
					outputChatBox( "That character is already buried.", player, 230, 95, 95, false )
				else
					outputChatBox( "That character is not character killed.", player, 230, 95, 95, false )
				end
			else
				outputChatBox( "Could not find a character with that name.", player, 230, 95, 95, false )
			end
		end
	end
)

addCommandHandler( { "makeadmin", "setlevel", "setadminlevel" },
	function( player, cmd, targetPlayer, level )
		if ( exports.common:isPlayerServerSeniorAdmin( player ) ) then
			local level = tonumber( level )
			
			if ( not targetPlayer ) or ( not level ) then
				outputChatBox( "SYNTAX: /" .. cmd .. " [partial player name] [level]", player, 230, 180, 95, false )
				
				return
			end
			
			targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )
			
			if ( not targetPlayer ) then
				outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95, false )
				
				return
			end
			
			local levelName = exports.common:getLevelName( tonumber( level ) )
			
			if ( levelName ~= "" ) then
				exports.security:modifyElementData( targetPlayer, "account:level", level, true )
				
				exports.database:query( "UPDATE `accounts` SET `level` = ? WHERE `id` = ?", level, getElementData( targetPlayer, "database:id" ) )
				
				if ( level > 0 ) then
					triggerClientEvent( targetPlayer, "admin:showHUD", targetPlayer )
					triggerClientEvent( root, "admin:updateHUD", root )
				else
					triggerClientEvent( targetPlayer, "admin:hideHUD", targetPlayer )
				end
				
				outputChatBox( "Updated " .. exports.common:formatString( exports.common:getPlayerName( targetPlayer ) ) .. " level to " .. level .. " (" .. levelName .. ").", player, 95, 230, 95, false )
				outputChatBox( "Your administration level was updated to " .. level .. " (" .. levelName .. ").", targetPlayer, 230, 180, 95, false )
			else
				outputChatBox( "Such level does not exist.", player, 230, 95, 95, false )
			end
		end
	end
)

addCommandHandler( "setskin",
	function( player, cmd, targetPlayer, skinID )
		if ( exports.common:isPlayerServerTrialAdmin( player ) ) then
			if ( not targetPlayer ) or ( not skinID ) then
				outputChatBox( "SYNTAX: /" .. cmd .. " [partial player name] [skin id]", player, 230, 180, 95, false )
				
				return
			end
			
			targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )
			
			if ( not targetPlayer ) then
				outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95, false )
				
				return
			end
			
			local skinID = tonumber( skinID )
			local foundSkin = false
			
			for _, _skinID in ipairs( getValidPedModels( ) ) do
				if ( _skinID == skinID ) then
					foundSkin = true
				end
			end
			
			if ( foundSkin ) then
				exports.database:query( "UPDATE `characters` SET `skin_id` = ? WHERE `id` = ?", skinID, getElementData( targetPlayer, "database:id" ) )
				
				setElementModel( targetPlayer, skinID )
				
				outputChatBox( "Updated " .. exports.common:formatString( exports.common:getPlayerName( targetPlayer ) ) .. " skin ID to " .. skinID .. ".", player, 95, 230, 95, false )
			else
				outputChatBox( "Such skin does not exist.", player, 230, 95, 95, false )
			end
		end
	end
)

addCommandHandler( { "toggleduty", "adminduty", "toggleadminduty", "togduty", "aduty", "admin" },
	function( player, cmd )
		if ( exports.common:isPlayerServerTrialAdmin( player ) ) then
			local newStatus = not exports.common:isOnDuty( player )
			
			exports.security:modifyElementData( player, "account:duty", newStatus, true )
			
			triggerClientEvent( player, "admin:updateHUD", player )
			
			outputChatBox( "You are now " .. ( newStatus and "on" or "off" ) .. " admin duty mode.", player, 230, 180, 95, false )
		end
	end
)

addCommandHandler( { "announce", "announcement", "message" },
	function( player, cmd, ... )
		if ( exports.common:isPlayerServerTrialAdmin( player ) ) then
			exports.messages:createMessage( root, table.concat( { ... }, " " ), getTickCount( ) )
		end
	end
)