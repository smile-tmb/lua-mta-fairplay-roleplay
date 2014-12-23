screenWidth, screenHeight = guiGetScreenSize( )

addEventHandler( "onClientRender", root,
	function( )
		dxDrawRectangle( 0, 0, screenWidth, screenHeight, tocolor( 255, 255, 255, 255 ) )
		
		local smoothness = 0.000625
		local power = 5
		local i = 0
		local counter = 0
		local increase = math.pi / 100
		
		while ( i < 1 ) do
			i = i + smoothness
			
			local x = i
			local y = math.pow( i, power )
			
			local oldX = i
			local oldY = math.pow( ( i - smoothness ) * ( i - smoothness ), power )
			
			local x = screenWidth * x
			local y = screenHeight * y
			
			local oldX = screenWidth * oldX
			local oldY = screenHeight * oldY
			
			local y = math.sin( counter )
			
			counter = counter + increase
			
			--outputConsole( x .. ", " .. y )
			--outputConsole( oldX .. ", " .. oldY )
			
			dxDrawLine( oldX, oldY, x, y, tocolor( 200, 100, 100, 255 ), 5 )
		end
	end
)