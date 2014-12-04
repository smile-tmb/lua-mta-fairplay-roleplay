local defaultLowestPriority = 5
local adminLevels = {
	[ 9 ] = { name = "Community Director", 		priority = 200, community = true },
	[ 8 ] = { name = "Community Senior Admin", 	priority = 175, community = true },
	[ 7 ] = { name = "Community Admin", 		priority = 150, community = true },
	[ 6 ] = { name = "Community Moderator", 	priority = 125, community = true },
	[ 5 ] = { name = "Server Manager", 			priority = 95 },
	[ 4 ] = { name = "Server Senior Admin", 	priority = 75 },
	[ 3 ] = { name = "Server Admin", 			priority = 50 },
	[ 2 ] = { name = "Server Junior Admin", 	priority = 25 },
	[ 1 ] = { name = "Server Trial Admin", 		priority = 5 },
	[ 0 ] = { name = "Player",					priority = 0 }
}

function getLevels( )
	return adminLevels
end

function getLevelPriority( level )
	local priority = adminLevels[ level ] and adminLevels[ level ].priority or 0
	
	return priority
end

function getLevelName( level )
	local name = adminLevels[ level ] and adminLevels[ level ].name or ""
	
	return name
end

function isCommunityAdmin( level )
	local status = adminLevels[ level ] and adminLevels[ level ].community or false
	
	return status
end

function isPriorityHigher( levelFrom, levelTo )
	local levelFromPriority = getLevelPriority( levelFrom )
	local levelToPriority = getLevelPriority( levelTo )
	
	if ( levelFromPriority > levelToPriority ) then
		return true
	end
	
	return false
end

function getPlayerLevel( player )
	local playerLevel = getElementData( player, "account:level" ) and tonumber( getElementData( player, "account:level" ) ) or 0
	
	return playerLevel
end

function isPlayerCommunityAdmin( player )
	return isCommunityAdmin( getPlayerLevel( player ) )
end

function isPlayerPriorityHigher( playerFrom, playerTo )
	return isPriorityHigher( getPlayerLevel( playerFrom ), getPlayerLevel( playerTo ) )
end

function getPriorityPlayers( lowestPriority, highestPriority )
	lowestPriority = lowestPriority or defaultLowestPriority
	highestPriority = highestPriority or 1337
	local priorityPlayers = { }
	
	for _, player in ipairs( getElementsByType( "player" ) ) do
		local levelPriority = getLevelPriority( getPlayerLevel( player ) )
		
		if ( levelPriority >= lowestPriority ) and ( levelPriority <= highestPriority ) then
			table.insert( priorityPlayers, player )
		end
	end
	
	return priorityPlayers
end

function isOnDuty( player )
	return getElementData( player, "account:duty" ) and true or false
end

function isPlayerServerTrialAdmin( player )
	return getPlayerLevel( player ) >= 1
end

function isPlayerServerJuniorAdmin( player )
	return getPlayerLevel( player ) >= 2
end

function isPlayerServerAdmin( player )
	return getPlayerLevel( player ) >= 3
end

function isPlayerServerSeniorAdmin( player )
	return getPlayerLevel( player ) >= 4
end

function isPlayerServerManager( player )
	return getPlayerLevel( player ) >= 5
end

function isPlayerCommunityModerator( player )
	return getPlayerLevel( player ) >= 6
end

function isPlayerCommunityAdmin( player )
	return getPlayerLevel( player ) >= 7
end

function isPlayerCommunitySeniorAdmin( player )
	return getPlayerLevel( player ) >= 8
end

function isPlayerCommunityDirector( player )
	return getPlayerLevel( player ) >= 9
end