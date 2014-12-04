addCommandHandler( { "cursor", "togcursor", "togglecursor" },
	function( )
		showCursor( not isCursorShowing( ) )
	end
)