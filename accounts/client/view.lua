local viewEnabled = false
local viewIndex = 1
local viewTimer
local viewPoints = {
	{
		posX = 332.01,
		posY = -2091.49,
		posZ = 22.87,
		aimX = 371.45,
		aimY = -2035.22,
		aimZ = 20.35,
		roll = 0,
		fov = 70,
		speed = 15000,
		wait = 500,
		reset = true
	},
	{
		posX = 355.18,
		posY = -2015.13,
		posZ = 10.34,
		aimX = 384.77,
		aimY = -2044.13,
		aimZ = 13.75,
		roll = 0,
		fov = 70,
		speed = 15000,
		wait = 500
	},
	{
		posX = 1952.36,
		posY = -1441.8,
		posZ = 57.23,
		aimX = 1922.16,
		aimY = -1399.36,
		aimZ = 54.79,
		roll = 0,
		fov = 70,
		speed = 15000,
		wait = 500,
		reset = true
	},
	{
		posX = 1884.1,
		posY = -1493.31,
		posZ = 57.93,
		aimX = 1866.06,
		aimY = -1416.63,
		aimZ = 56.95,
		roll = 0,
		fov = 70,
		speed = 15000,
		wait = 500
	},
	{
		posX = 1650.9,
		posY = -1509.6,
		posZ = 58.4,
		aimX = 1629.38,
		aimY = -1552.92,
		aimZ = 51.61,
		roll = 0,
		fov = 70,
		speed = 15000,
		wait = 500,
		reset = true
	},
	{
		posX = 1735.21,
		posY = -1551.46,
		posZ = 59.11,
		aimX = 1703.77,
		aimY = -1589.86,
		aimZ = 50.97,
		roll = 0,
		fov = 70,
		speed = 15000,
		wait = 500
	}
}

function moveToNextView( )
	local view = viewPoints[ viewIndex ]
	
	if ( view.reset ) then
		if ( viewPoints[ viewIndex + 1 ] ) then
			viewIndex = viewIndex + 1
		else
			viewIndex = 1
		end
	end
	
	view = viewPoints[ viewIndex ]
	local lastViewIndex = viewIndex - 1 > 0 and viewIndex - 1 or #viewPoints
	local lastView = viewPoints[ lastViewIndex ]
	
	if ( lastView.reset ) then
		setCameraMatrix( lastView.posX, lastView.posY, lastView.posZ, lastView.aimX, lastView.aimY, lastView.aimZ, view.roll or 0, view.fov or 70 )
	end
	
	exports.common:smoothMoveCamera( lastView.posX, lastView.posY, lastView.posZ, lastView.aimX, lastView.aimY, lastView.aimZ, view.posX, view.posY, view.posZ, view.aimX, view.aimY, view.aimZ, view.speed, view.easing or nil, view.roll or nil, view.fov or nil )
	
	viewTimer = setTimer( moveToNextView, view.speed + view.wait, 1 )
	
	if ( viewPoints[ viewIndex + 1 ] ) then
		viewIndex = viewIndex + 1
	else
		viewIndex = 1
	end
end

function showView( )
	if ( not viewEnabled ) then
		hideView( )
		moveToNextView( )
		
		viewEnabled = true
	end
end
addEvent( "accounts:showView", true )
addEventHandler( "accounts:showView", root, showView )
--addEventHandler( "onClientResourceStart", resourceRoot, showView )

function hideView( )
	if ( viewEnabled ) then
		if ( isTimer( viewTimer ) ) then
			killTimer( viewTimer )
		end
		
		exports.common:stopSmoothMoveCamera( )
		
		viewEnabled = false
	end
end
addEvent( "accounts:hideView", true )
addEventHandler( "accounts:hideView", root, hideView )