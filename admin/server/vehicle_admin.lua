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