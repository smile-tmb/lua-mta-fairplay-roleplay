local isCameraMoving = false
local smoothStopTimer
local smoothMovers = { }
local cameraRoll, cameraFoV = 0, 70

local function render( )
	local posX, posY, posZ = getElementPosition( smoothMovers.source )
	local aimX, aimY, aimZ = getElementPosition( smoothMovers.target )
	
	setCameraMatrix( posX, posY, posZ, aimX, aimY, aimZ, cameraRoll, cameraFoV )
end

function stopSmoothMoveCamera( )
	if ( isCameraMoving ) then
		if ( isTimer( smoothStopTimer ) ) then
			killTimer( smoothStopTimer )
		end
		
		if ( isElement( smoothMovers.source ) ) then
			destroyElement( smoothMovers.source )
		end
		
		if ( isElement( smoothMovers.target ) ) then
			destroyElement( smoothMovers.target )
		end
		
		removeEventHandler( "onClientPreRender", root, render )
		
		isCameraMoving = false
	end
end
addEvent( "common:stop_camera", true )
addEventHandler( "common:stop_camera", root, stopSmoothMoveCamera )

function smoothMoveCamera( x1, y1, z1, x1t, y1t, z1t, x2, y2, z2, x2t, y2t, z2t, time, easing, roll, fov )
	if ( isCameraMoving ) then
		return false
	end
	
	cameraRoll = roll or 0
	cameraFoV = fov or 70
	
	smoothMovers.source = createObject( 1337, x1, y1, z1 )
	smoothMovers.target = createObject( 1337, x1t, y1t, z1t )
	
	setElementAlpha( smoothMovers.source, 0 )
	setElementAlpha( smoothMovers.target, 0 )
	
	setElementCollisionsEnabled( smoothMovers.source, false )
	setElementCollisionsEnabled( smoothMovers.target, false )
	
	moveObject( smoothMovers.source, time, x2, y2, z2, 0, 0, 0, easing or "InOutQuad" )
	moveObject( smoothMovers.target, time, x2t, y2t, z2t, 0, 0, 0, easing or "InOutQuad" )
	
	addEventHandler( "onClientPreRender", root, render )
	
	isCameraMoving = true
	
	smoothStopTimer = setTimer( stopSmoothMoveCamera, time, 1 )
	
	return true
end
addEvent( "common:move_camera", true )
addEventHandler( "common:move_camera", root, smoothMoveCamera )