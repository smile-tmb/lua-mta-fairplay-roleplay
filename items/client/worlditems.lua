addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		for _, object in ipairs( getElementsByType( "object" ) ) do
			if ( getElementData( object, "worlditem.id" ) ) then
				setObjectBreakable( object, false )
			end
		end
	end
)