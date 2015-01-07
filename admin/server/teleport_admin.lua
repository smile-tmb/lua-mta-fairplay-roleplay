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