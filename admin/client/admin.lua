addEventHandler( "onClientPlayerDamage", root,
	function( )
		if ( exports.common:isOnDuty( source ) ) then
			cancelEvent( )
		end
	end
)