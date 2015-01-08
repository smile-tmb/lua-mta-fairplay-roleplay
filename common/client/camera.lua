--[[
	The MIT License (MIT)

	Copyright (c) 2014 Socialz (+ soc-i-alz GitHub organization)

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]

local isCameraMoving = false

local smoothStopTimer
local smoothMovers = { }

local cameraStartTick = 0
local cameraRoll, cameraFoV = 0, 70
local cameraNewRoll, cameraNewFoV = cameraRoll, cameraFoV

local function render( )
	local posX, posY, posZ = getElementPosition( smoothMovers.source )
	local aimX, aimY, aimZ = getElementPosition( smoothMovers.target )
	
	cameraRoll, cameraFoV = interpolateBetween( cameraRoll, cameraFoV, 0, cameraNewRoll, cameraNewFoV, 0, ( getTickCount( ) - cameraStartTick ) / cameraSpeed, "InOutQuad" )
	
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
	
	time = time < 50 and 50 or time
	
	cameraStartTick = getTickCount( )
	cameraSpeed = time
	cameraNewRoll = roll or 0
	cameraNewFoV = fov or 70
	
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