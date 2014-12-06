local IDs = { }

function givePlayerID( player )
	local playerID = exports.common:nextIndex( IDs )
	
	IDs[ playerID ] = player
	
	exports.security:modifyElementData( player, "player:id", playerID, true )
end

addEventHandler( "onPlayerQuit", root,
	function( )
		local playerID = exports.common:getPlayerID( source )
		
		if ( playerID ) then
			IDs[ playerID ] = false
		end
	end
)