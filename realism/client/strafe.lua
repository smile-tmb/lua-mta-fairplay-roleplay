addEventHandler( "onClientPreRender", root,
	function( )
		local leftPressed = getKeyState( "q" )
		local rightPressed = getKeyState( "e" )
		
		if ( ( leftPressed ) or ( rightPressed ) ) and ( not isMTAWindowActive( ) ) and ( not isCursorShowing( ) ) then
			setControlState( "forwards", true )
			--setControlState( "sprint", true )
			
			if ( leftPressed ) then
				setControlState( "left", true )
			elseif ( rightPressed ) then
				setControlState( "right", true )
			end
		else
			setControlState( "forwards", false )
			setControlState( "left", false )
			setControlState( "right", false )
			--setControlState( "sprint", false )
		end
	end
)