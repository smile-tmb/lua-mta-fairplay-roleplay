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

addCommandHandler( { "createfaction", "makefaction" },
	function( player, cmd, factionType, ... )
		if ( exports.common:isPlayerServerSeniorAdmin( player ) ) then
			local factionType = factionType and tonumber( factionType ) or false
			local factionName = table.concat( { ... }, " " )
			
			if ( factionType ) and ( factionName ) and ( factionName:len( ) > 1 ) then
				if ( not exports.factions:getFactionByName( factionName ) ) then
					local faction = exports.factions:createFaction( factionName, factionType )
					
					if ( faction ) then
						outputChatBox( "You created a faction for " .. faction.name .. " with ID " .. faction.id .. ".", player, 95, 230, 95 )
					else
						outputChatBox( "Something went wrong when creating or loading the faction. Please retry.", player, 230, 95, 95 )
					end
				else
					outputChatBox( "A faction with that name already exists.", player, 230, 95, 95 )
				end
			else
				outputChatBox( "SYNTAX: /" .. cmd .. " [faction type: 1=other, 2=law, 3=medical, 4=news, 5=gang, 6=mafia] [faction name]", player, 230, 180, 95 )
			end
		end
	end
)

addCommandHandler( { "deletefaction", "removefaction" },
	function( player, cmd, factionID )
		if ( exports.common:isPlayerServerSeniorAdmin( player ) ) then
			local factionID = factionID and tonumber( factionID ) or false
			
			if ( factionID ) then
				local faction = exports.factions:getFactionByID( factionID )
				
				if ( faction ) then
					if ( exports.factions:deleteFaction( factionID ) ) then
						outputChatBox( "You deleted faction of " .. faction.name .. " (" .. faction.id .. ").", player, 95, 230, 95 )
					else
						outputChatBox( "Something went wrong when deleting the faction. Please retry.", player, 230, 95, 95 )
					end
				else
					outputChatBox( "Could not find a faction with that identifier.", player, 230, 95, 95 )
				end
			else
				outputChatBox( "SYNTAX: /" .. cmd .. " [faction id]", player, 230, 180, 95 )
			end
		end
	end
)

addCommandHandler( { "addplayerfaction", "addplayertofaction", "addtofaction" },
	function( player, cmd, targetPlayer, factionID )
		if ( exports.common:isPlayerServerAdmin( player ) ) then
			local factionID = tonumber( factionID )
			
			if ( targetPlayer ) and ( factionID ) then
				targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )
				
				if ( targetPlayer ) then
					local faction = exports.factions:getFactionByID( factionID )
					
					if ( faction ) then
						if ( not exports.factions:isCharacterInFaction( targetPlayer, factionID ) ) then
							if ( exports.factions:addCharacterToFaction( exports.common:getCharacterID( targetPlayer ), factionID ) ) then
								outputChatBox( "You were added to " .. faction.name .. ".", targetPlayer, 230, 180, 95 )
								outputChatBox( exports.common:getPlayerName( targetPlayer ) .. " was added to faction " .. faction.name .. " (" .. factionID .. ").", player, 95, 230, 95 )
							else
								outputChatBox( "Something went wrong when adding targeted player to the faction. Please retry.", player, 230, 95, 95 )
							end
						else
							outputChatBox( "Targeted player is already in that faction.", player, 230, 95, 95 )
						end
					else
						outputChatBox( "Could not find a faction with that identifier.", player, 230, 95, 95 )
					end
				else
					outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95 )
				end
			else
				outputChatBox( "SYNTAX: /" .. cmd .. " [partial player name] [faction id]", player, 230, 180, 95 )
			end
		end
	end
)

addCommandHandler( { "removeplayerfaction", "removeplayerfromfaction", "removefromfaction" },
	function( player, cmd, targetPlayer, factionID )
		if ( exports.common:isPlayerServerAdmin( player ) ) then
			local factionID = tonumber( factionID )
			
			if ( targetPlayer ) and ( factionID ) then
				targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )
				
				if ( targetPlayer ) then
					local faction = exports.factions:getFactionByID( factionID )
					
					if ( faction ) then
						if ( exports.factions:isCharacterInFaction( targetPlayer, factionID ) ) then
							if ( exports.factions:removeCharacterFromFaction( exports.common:getCharacterID( targetPlayer ), factionID ) ) then
								outputChatBox( "You were removed from " .. faction.name .. ".", targetPlayer, 230, 180, 95 )
								outputChatBox( exports.common:getPlayerName( targetPlayer ) .. " was removed from faction " .. faction.name .. " (" .. factionID .. ").", player, 95, 230, 95 )
							else
								outputChatBox( "Something went wrong when removing targeted player from the faction. Please retry.", player, 230, 95, 95 )
							end
						else
							outputChatBox( "Targeted player is not in that faction.", player, 230, 95, 95 )
						end
					else
						outputChatBox( "Could not find a faction with that identifier.", player, 230, 95, 95 )
					end
				else
					outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95 )
				end
			else
				outputChatBox( "SYNTAX: /" .. cmd .. " [partial player name] [faction id]", player, 230, 180, 95 )
			end
		end
	end
)