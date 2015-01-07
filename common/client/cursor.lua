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

function isWithin2DBounds( sourceX, sourceY, targetX, targetY, targetWidth, targetHeight )
	if ( sourceX >= targetX ) and ( sourceX <= targetX + targetWidth ) and
	   ( sourceY >= targetY ) and ( sourceY <= targetY + targetHeight ) then
		return true
	end
	
	return false
end