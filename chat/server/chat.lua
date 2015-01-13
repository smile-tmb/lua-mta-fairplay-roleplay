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

local _outputChatBox = outputChatBox
function outputChatBox( text, visibleTo, r, g, b, colorCoded )
	if ( string.len( text ) > 128 ) then
		_outputChatBox( string.sub( text, 1, 127 ), visibleTo, r, g, b, colorCoded )
		outputChatBox( " " .. string.sub( text, 128 ), visibleTo, r, g, b, colorCoded )
	else
		_outputChatBox( text, visibleTo, r, g, b, colorCoded )
	end
end

function outputLocalChat( player, message, originalDistance )
	if ( not exports.common:isPlayerPlaying( player ) ) then
		return
	end
	
	local posX, posY, posZ = getElementPosition( player )
	
	local vehicle = getPedOccupiedVehicle( player )
	local vehicleModel, vehicleType = "", "Vehicle"
	
	local isBike = false
	local isWindowless = false
	local isRoofless = false
	
	if ( vehicle ) then
		vehicleModel = getElementModel( vehicle ) or false
		vehicleType = getVehicleType( vehicle ) or false
		
		isBike = exports.vehicles:getBikeModels( )[ vehicleModel ] or false
		isWindowless = exports.vehicles:getWindowlessModels( )[ vehicleModel ] or false
		isRoofless = exports.vehicles:getRooflessModels( )[ vehicleModel ] or false
	end
	
	local vehiclePrefix = ""
	
	if ( vehicle ) then
		if ( isBike ) then
			vehiclePrefix = "(On Bike) "
		else
			if ( vehicleType == "Automobile" ) then
				vehiclePrefix = "(In Car) "
			else
				vehiclePrefix = "(In " .. vehicleType .. ") "
			end
		end
	end
	
	local senderLanguage, senderSkill = getPlayerLanguage( player, 1 )
	
	if ( not senderLanguage ) then
		outputChatBox( "Wops, you do not have a language!", player, 230, 95, 95 )
		return
	end
	
	local senderLanguageName = getLanguageName( senderLanguage )
	
	local languagePrefix = "[" .. senderLanguageName .. "] "
	
	distance = tonumber( originalDistance ) or 3000 * 3000 * 2
	
	for _, targetPlayer in ipairs( getElementsByType( "player" ) ) do
		local targetX, targetY, targetZ = getElementPosition( targetPlayer )
		local targetDistance = getDistanceBetweenPoints3D( posX, posY, posZ, targetX, targetY, targetZ )
		
		if ( distance == 10000 ) or ( targetDistance < distance ) and ( ( getElementInterior( targetPlayer ) == getElementInterior( player ) ) and ( getElementDimension( targetPlayer ) == getElementDimension( player ) ) ) then
			local r, g, b = 240, 240, 240
			
			if ( targetDistance > 8 ) then
				r, g, b = r - targetDistance * 2, g - targetDistance * 2, b - targetDistance * 2
			end
			
			if ( not hasLanguage( targetPlayer, senderLanguage ) ) then
				if ( player ~= targetPlayer ) then
					local length = string.len( message )
					local percent = 100 - math.min( getPlayerLanguageSkill( targetPlayer, senderLanguage ), senderSkill )
					local replace = ( percent / 100 ) * length
					
					if ( senderLanguage == 1337 ) then
						message = hash( "md5", message )
					else
						local i = 1
						
						while ( i < replace ) do
							local letter = string.sub( message, i, i )
							
							if ( letter ~= "" ) and ( letter ~= " " ) then
								local replaceLetter
								
								if ( string.byte( letter ) >= 65 ) and ( string.byte( letter ) <= 90 ) then
									replaceLetter = string.char(math.random( 65, 90 ) )
								elseif ( string.byte( letter ) >= 97 ) and ( string.byte( letter ) <= 122 ) then
									replaceLetter = string.char( math.random( 97, 122 ) )
								end
								
								if ( string.byte( letter ) >= 65 and string.byte( letter ) <= 90 ) or ( string.byte( letter ) >= 97 and string.byte( letter ) <= 122 ) then
									message = string.gsub( message, tostring( letter ), replaceLetter, 1 )
								end
							end
							
							i = i + 1
						end
					end
				end
			else
				if ( senderSkill < 100 ) then
					if ( senderSkill > getPlayerLanguageSkill( targetPlayer, senderLanguage ) ) or ( getPlayerLanguageSkill( targetPlayer, senderLanguage ) < 85 ) then
						increaseLanguageSkill( player, senderLanguage )
					end
				end
			end
			
			local typePrefix = ""
			
			if ( distance == 0.9 ) then
				typePrefix = "(Close Whisper) "
			elseif ( distance == 3 ) then
				typePrefix = "(Whisper) "
			elseif ( distance == 40 ) then
				typePrefix = "(Shout) "
			elseif ( distance == 60 ) then
				typePrefix = "(Megaphone) "
			end
			
			local isOnDuty = exports.common:isOnDuty( targetPlayer )
			local prefixes = typePrefix .. vehiclePrefix .. ( isOnDuty and languagePrefix or "" )
			
			message = exports.common:cleanString( message )
			
			local firstLetter, restMessage = string.upper( message:sub( 1, 1 ) ), message:sub( 2 )
			
			message = firstLetter .. restMessage
			
			if ( distance <= 60 ) then
				if ( ( vehicle ) and ( ( isOnDuty ) or ( ( not isOnDuty ) and ( exports.vehicles:isVehicleWindowsDown( vehicle ) or isBike or isWindowless or isRoofless or getPedOccupiedVehicle( targetPlayer ) == vehicle ) ) ) or ( not vehicle ) ) then
					outputChatBox( prefixes .. exports.common:getPlayerName( player ) .. " says: " .. message, targetPlayer, r, g, b, false )
				end
			else
				if ( originalDistance ) then
					if ( string.find( originalDistance, "r" ) ) then
						local frequency = string.gsub( originalDistance, "r", "" )
						
						if ( exports.items:hasItem( targetPlayer, 13, frequency ) ) or ( getDistanceBetweenPoints3D( posX, posY, posZ, targetX, targetY, targetZ ) <= 20 ) then
							outputChatBox( "[#" .. frequency .. "] " .. prefixes .. exports.common:getPlayerName( player ) .. " says: " .. message, targetPlayer, 95, 95, 220, false )
						end
					end
				end
			end
		end
	end
end

function outputLocalActionMe( player, action )
	if ( exports.common:isPlayerPlaying( player ) ) then
		local x, y, z = getElementPosition( player )
		local affected = ""
		
		action = exports.common:cleanString( action )
		
		for _, targetPlayer in ipairs( getElementsByType( "player" ) ) do
			local px, py, pz = getElementPosition( targetPlayer )
			local distance = getDistanceBetweenPoints3D( px, py, pz, x, y, z )
			
			if ( distance < 30 ) and ( getElementInterior( player ) == getElementInterior( targetPlayer ) ) and ( getElementDimension( player ) == getElementDimension( targetPlayer ) ) then
				outputChatBox( " *" .. exports.common:getPlayerName( player ) .. " " .. action, targetPlayer, 237, 116, 136, false )
			end
		end
	end
end