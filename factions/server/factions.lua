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

local factions = { }

function getFactions( )
	return factions
end

function getFactionByID( id )
	for index, faction in pairs( getFactions( ) ) do
		if ( faction.id == id ) then
			return faction, index
		end
	end
	
	return false
end

function getFactionByName( name )
	for index, faction in pairs( getFactions( ) ) do
		if ( faction.name == name ) then
			return faction, index
		end
	end
	
	return false
end

function createFaction( name, type )
	local type = type or 1
	local ranks = { }

	for i = 1, factionRankCount do
		table.insert( ranks, {
			name = "Rank #" .. i,
			wage = 0
		} )
	end

	local id = exports.database:insert_id( "INSERT INTO `factions` (`name`, `type`, `ranks`) VALUES (?, ?, ?)", name, type, toJSON( ranks ) )

	return id and loadFaction( id ) or false
end

function deleteFaction( id )
	local found, index = getFactionByID( id )

	if ( found ) then
		if ( exports.database:execute( "DELETE FROM `factions` WHERE `id` = ?", id ) ) then
			factions[ index ] = nil

			exports.database:execute( "DELETE FROM `factions_characters` WHERE `faction_id` = ?", id )

			return true
		end
	end

	return false
end

function addCharacterToFaction( characterID, id, rank, isLeader )
	rank = tonumber( rank ) or 1
	isLeader = type( isLeader ) == "boolean" and isLeader or false
	
	if ( not isCharacterInFaction( characterID, id ) ) and ( exports.database:execute( "INSERT INTO `factions_characters` (`character_id`, `faction_id`, `rank`, `is_leader`) VALUES (?, ?, ?, ?)", characterID, id, rank, isLeader ) ) then
		local faction = getFactionByID( id )

		table.insert( faction.players, { id = characterID, rank = rank, leader = isLeader } )

		for _, data in pairs( faction.players ) do
			local player = exports.common:getPlayerByCharacterID( data.id )

			if ( player ) then
				triggerClientEvent( player, "factions:update", player, faction )
			end
		end

		return true
	end

	return false
end

function addPlayerToFaction( player, id )
	return addCharacterToFaction( exports.common:getCharacterID( player ), id )
end

function removeCharacterFromFaction( characterID, id )
	local index = isCharacterInFaction( characterID, id )

	if ( index ) and ( exports.database:execute( "DELETE FROM `factions_characters` WHERE `character_id` = ? AND `faction_id` = ?", characterID, id ) ) then
		local faction = getFactionByID( id )

		table.remove( faction.players, index )

		for _, data in pairs( faction.players ) do
			local player = exports.common:getPlayerByCharacterID( data.id )

			if ( player ) then
				triggerClientEvent( player, "factions:update", player, faction )
			end
		end

		return true
	end

	return false
end

function removePlayerFromFaction( player, id )
	return removeCharacterFromFaction( exports.common:getCharacterID( player ), id )
end

function isCharacterInFaction( characterID, id, checkForLeadership )
	local faction = getFactionByID( id )

	if ( faction ) then
		for index, data in pairs( faction.players ) do
			if ( data.id == characterID ) and ( ( not checkForLeadership ) or ( data.leader ) ) then
				return index
			end
		end
	end

	return false
end

function isPlayerInFaction( player, id, checkForLeadership )
	return isCharacterInFaction( exports.common:getCharacterID( player ), id, checkForLeadership )
end

function getCharacterFactions( characterID )
	local query = exports.database:query( "SELECT `faction_id` FROM `factions_characters` WHERE `character_id` = ?", id )

	if ( query ) then
		local playerFactions = { }

		for _, data in ipairs( query ) do
			table.insert( playerFactions, data.faction_id )
		end

		return playerFactions
	end

	return false
end

function getPlayerFactions( player, id )
	return getCharacterFactions( exports.common:getCharacterID( player ) )
end

function setCharacterFactionRank( characterID, id, rank )
	rank = tonumber( rank ) or 1
	rank = math.max( 1, math.min( factionRankCount, rank ) )
	local index = isCharacterInFaction( characterID, id )

	if ( index ) and ( rank ) and ( exports.database:execute( "UPDATE `factions_characters` SET `rank` = ? WHERE `character_id` = ? AND `faction_id` = ?", rank, characterID, id ) ) then
		local faction = getFactionByID( id )
		
		
		faction.players[ index ].rank = rank

		for _, data in pairs( faction.players ) do
			local player = exports.common:getPlayerByCharacterID( data.id )

			if ( player ) then
				triggerClientEvent( player, "factions:update", player, faction )
			end
		end

		return true, rank
	end

	return false
end

function setPlayerFactionRank( player, id, rank )
	return setCharacterFactionRank( exports.common:getCharacterID( player ), id, rank )
end

function setCharacterFactionLeader( characterID, id, isLeader )
	isLeader = type( isLeader ) == "boolean" and isLeader or false
	local index = isCharacterInFaction( characterID, id )

	if ( index ) and ( exports.database:execute( "UPDATE `factions_characters` SET `is_leader` = ? WHERE `character_id` = ? AND `faction_id` = ?", isLeader, characterID, id ) ) then
		local faction = getFactionByID( id )
		
		
		faction.players[ index ].leader = isLeader

		for _, data in pairs( faction.players ) do
			local player = exports.common:getPlayerByCharacterID( data.id )

			if ( player ) then
				triggerClientEvent( player, "factions:update", player, faction )
			end
		end

		return true
	end

	return false
end

function setPlayerFactionLeader( player, id, isLeader )
	return setCharacterFactionLeader( exports.common:getCharacterID( player ), id, isLeader )
end

function loadFaction( id )
	local _, index = getFactionByID( id )

	if ( factions[ index ] ) then
		factions[ index ] = nil
	end

	local query = exports.database:query_single( "SELECT * FROM `factions` WHERE `id` = ? LIMIT 1", id )

	if ( query ) then
		local ranks = fromJSON( query.ranks )
		local faction = {
			id = query.id,
			name = query.name,
			motd = query.motd,
			ranks = ranks,
			players = { }
		}

		for i = 1, factionRankCount do
			if ( not faction.ranks[ i ] ) then
				faction.ranks[ i ] = {
					name = "Rank #" .. i,
					wage = 0
				}
			end
		end

		if ( exports.common:count( faction.ranks ) ~= exports.common:count( ranks ) ) then
			exports.database:execute( "UPDATE `factions` SET `ranks` = ? WHERE `id` = ?", toJSON( faction.ranks ) )
		end

		local players = exports.database:query( "SELECT `character_id` FROM `factions_characters` WHERE `faction_id` = ?", query.id )

		if ( players ) then
			for _, data in ipairs( players ) do
				local rank = tonumber( data.rank ) or 1

				if ( not faction.ranks[ rank ] ) then
					rank = math.min( factionRankCount, math.max( 1, rank ) )

					exports.database:execute( "UPDATE `faction_characters` SET `rank` = ? WHERE `character_id` = ?", rank, data.character_id )
				end

				table.insert( faction.players, { id = data.character_id, rank = data.rank, leader = data.is_leader == 1 } )

				local player = exports.common:getPlayerByCharacterID( data.character_id )

				if ( player ) then
					triggerClientEvent( player, "factions:update", player, faction )
				end
			end
		end

		table.insert( factions, faction )

		return getFactionByID( id )
	end

	return false
end

function loadFactions( )
	local query = exports.database:query( "SELECT * FROM `factions`" )

	if ( query ) then
		for _, data in ipairs( query ) do
			loadFaction( data.id )
		end

		return true
	end

	return false
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		loadFactions( )
	end
)