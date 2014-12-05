addEventHandler( "onResourceStart", root,
	function( resource )
		if ( resource ) and ( getResourceName( resource ) == "items" ) then
			restartResource( getThisResource( ) )
		end
	end
)