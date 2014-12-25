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
			
			local playerName = exports.common:getPlayerName( targetPlayer )
			
			outputChatBox( ( targetPlayer ~= player and exports.common:formatPlayerName( playerName ) or "Your" ) .. " position:", player, 230, 180, 95, false )
			outputChatBox( " Position: " .. x .. ", " .. y .. ", " .. z, player, 230, 180, 95, false )
			outputChatBox( " Rotation: " .. rotation .. ", Interior: " .. interior .. ", Dimension: " .. dimension, player, 230, 180, 95, false )
		end
	end
)

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