addCommandHandler( { "getpos", "pos", "getposition", "getxyz", "getloc", "loc", "getlocation" },
	function( player, cmd, targetPlayer )
		if ( exports.common:isPlayerServerTrialAdmin( player ) ) then
			if ( targetPlayer ) then
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
			
			local playerName = getPlayerName( targetPlayer )
			
			outputChatBox( ( targetPlayer ~= player and exports.common:formatPlayerName( playerName ) or "Your" ) .. " position:", player, 230, 180, 95, false )
			outputChatBox( " Position: " .. x .. ", " .. y .. ", " .. z, player, 230, 180, 95, false )
			outputChatBox( " Rotation: " .. rotation .. ", Interior: " .. interior .. ", Dimension: " .. dimension, player, 230, 180, 95, false )
		end
	end
)

addCommandHandler( { "makeadmin", "setlevel", "setadminlevel" },
	function( player, cmd, targetPlayer, level )
		if ( exports.common:isPlayerServerSeniorAdmin( player ) ) then
			if ( not targetPlayer ) or ( not level ) then
				outputChatBox( "SYNTAX: /" .. cmd .. " [partial player name] [level]", player, 230, 180, 95, false )
				
				return
			end
			
			targetPlayer = exports.common:getPlayerFromPartialName( targetPlayer, player )
			
			if ( not targetPlayer ) then
				outputChatBox( "Could not find a player with that identifier.", player, 230, 95, 95, false )
				
				return
			end
			
			local levelName = exports.common:getLevelName( level )
			
			if ( levelName ~= "" ) then
				exports.security:modifyElementData( player, "account:level", level, true )
				
				exports.database:query( "UPDATE `accounts` SET `level` = ? WHERE `id` = ?", level, getElementData( player, "database:id" ) )
				
				triggerClientEvent( root, "admin:updateHUD", root )
				
				outputChatBox( "Updated " .. exports.common:formatString( getPlayerName( targetPlayer ) ) .. " level to " .. level .. " (" .. levelName .. ").", player, 230, 180, 95, false )
			else
				outputChatBox( "Such level does not exist.", player, 230, 95, 95, false )
				
				return
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