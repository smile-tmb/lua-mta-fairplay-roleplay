addCommandHandler( { "cursor", "togcursor", "togglecursor" },
	function( )
		showCursor( not isCursorShowing( ) )
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		bindKey( "m", "down", "togcursor" )
	end
)