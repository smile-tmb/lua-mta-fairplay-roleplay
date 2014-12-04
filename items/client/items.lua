addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		if ( exports.common:isPlayerPlaying( localPlayer ) ) then
			triggerServerEvent( "items:get", localPlayer )
		end
	end
)