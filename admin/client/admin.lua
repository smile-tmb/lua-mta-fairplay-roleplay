addEventHandler( "onClientPlayerDamage", root,
	function( )
		if ( exports.common:isOnDuty( source ) ) or ( getElementData( source, "temp:in_tutorial" ) ) then
			cancelEvent( )
		end
	end
)