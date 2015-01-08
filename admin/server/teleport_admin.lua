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

addCommandHandler( { "getpos", "pos", "getposition", "getxyz", "getloc", "loc", "getlocation" },
	function( player, cmd, targetPlayer )
		if ( targetPlayer ) and ( exports.common:isPlayerServerTrialAdmin( player ) ) then
			targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )
			
			if ( not targetPlayer ) then
				outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95, false )
				
				return
			end
		else
			targetPlayer = player
		end
		
		local x, y, z = getElementPosition( targetPlayer )
		local rotation = getPedRotation( targetPlayer )
		local interior, dimension = getElementInterior( targetPlayer ), getElementDimension( targetPlayer )
		
		x, y, z = math.floor( x * 100 ) / 100, math.floor( y * 100 ) / 100, math.floor( z * 100 ) / 100
		rotation = math.floor( rotation * 100 ) / 100
		
		local playerName = exports.common:getPlayerName( targetPlayer )
		
		outputChatBox( ( targetPlayer ~= player and exports.common:formatPlayerName( playerName ) or "Your" ) .. " position:", player, 230, 180, 95, false )
		outputChatBox( " Position: " .. x .. ", " .. y .. ", " .. z, player, 230, 180, 95, false )
		outputChatBox( " Rotation: " .. rotation .. ", Interior: " .. interior .. ", Dimension: " .. dimension, player, 230, 180, 95, false )
	end
)

function teleportPlayer( player, playerTo )
	if ( isElement( player ) ) and ( isElement( playerTo ) ) then
		setElementPosition( player, getElementPosition( playerTo ) )
		setElementInterior( player, getElementInterior( playerTo ) )
		setElementDimension( player, getElementDimension( playerTo ) )
		
		return true
	end
	
	return false
end