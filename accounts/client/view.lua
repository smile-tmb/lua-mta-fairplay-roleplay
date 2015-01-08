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

local viewEnabled = false
local viewIndex = 1
local viewTimer
local viewPoints = {
	{
		posX = 355.18,
		posY = -2015.13,
		posZ = 10.34,
		aimX = 384.77,
		aimY = -2044.13,
		aimZ = 13.75,
		reset = true
	},
	{
		posX = 332.01,
		posY = -2091.49,
		posZ = 22.87,
		aimX = 371.45,
		aimY = -2035.22,
		aimZ = 20.35,
		speed = 15000,
		wait = 500
	},
	{
		posX = 1884.1,
		posY = -1493.31,
		posZ = 57.93,
		aimX = 1866.06,
		aimY = -1416.63,
		aimZ = 56.95,
		reset = true
	},
	{
		posX = 1952.36,
		posY = -1441.8,
		posZ = 57.23,
		aimX = 1922.16,
		aimY = -1399.36,
		aimZ = 54.79,
		speed = 15000,
		wait = 500
	},
	{
		posX = 1735.21,
		posY = -1551.46,
		posZ = 59.11,
		aimX = 1703.77,
		aimY = -1589.86,
		aimZ = 50.97,
		reset = true
	},
	{
		posX = 1650.9,
		posY = -1509.6,
		posZ = 58.4,
		aimX = 1629.38,
		aimY = -1552.92,
		aimZ = 51.61,
		speed = 15000,
		wait = 500
	},
	{
		posX = 1270.75,
		posY = -1448.81,
		posZ = 60.67,
		aimX = 1238.36,
		aimY = -1419.34,
		aimZ = 48.46,
		reset = true
	},
	{
		posX = 1288.34,
		posY = -1387.58,
		posZ = 43.7,
		aimX = 1236.03,
		aimY = -1366.18,
		aimZ = 27.63,
		speed = 15000,
		wait = 500
	},
	{
		posX = 1234.71,
		posY = -889.78,
		posZ = 99.23,
		aimX = 1272.56,
		aimY = -831.81,
		aimZ = 91.42,
		reset = true
	},
	{
		posX = 1456,
		posY = -886.55,
		posZ = 86.06,
		aimX = 1419.13,
		aimY = -820.43,
		aimZ = 77.92,
		speed = 15000,
		wait = 500
	},
	{
		posX = 1494.02,
		posY = -868.41,
		posZ = 71.7,
		aimX = 1549.87,
		aimY = -921.25,
		aimZ = 71.62,
		reset = true
	},
	{
		posX = 1409.22,
		posY = -917.05,
		posZ = 68.29,
		aimX = 1333.67,
		aimY = -926.57,
		aimZ = 63.2,
		speed = 15000,
		wait = 500
	},
	{
		posX = 634.39,
		posY = -1199.82,
		posZ = 19.65,
		aimX = 629.48,
		aimY = -1206.88,
		aimZ = 17.1,
		reset = true
	},
	{
		posX = 625.68,
		posY = -1212.96,
		posZ = 20.24,
		aimX = 610.22,
		aimY = -1239.29,
		aimZ = 38.65,
		speed = 15000,
		wait = 500
	},
	{
		posX = 1084.2,
		posY = -1661.73,
		posZ = 43.92,
		aimX = 1126.76,
		aimY = -1711.3,
		aimZ = 30.81,
		reset = true
	},
	{
		posX = 1142.84,
		posY = -1643.07,
		posZ = 44.81,
		aimX = 1197.27,
		aimY = -1568.83,
		aimZ = 67.34,
		speed = 15000,
		wait = 500
	},
	{
		posX = 1361.47,
		posY = -1632.74,
		posZ = 57.47,
		aimX = 1398.05,
		aimY = -1662.05,
		aimZ = 47.61,
		reset = true
	},
	{
		posX = 1424.94,
		posY = -1673.66,
		posZ = 37.58,
		aimX = 1445.65,
		aimY = -1702.9,
		aimZ = 52.3,
		speed = 15000,
		wait = 500
	},
	{
		posX = 2215.87,
		posY = -1741.28,
		posZ = 58.25,
		aimX = 2216.99,
		aimY = -1797.69,
		aimZ = 43.65,
		reset = true
	},
	{
		posX = 2235.32,
		posY = -1726.06,
		posZ = 46.16,
		aimX = 2289.33,
		aimY = -1699.87,
		aimZ = 29.65,
		speed = 15000,
		wait = 500
	},
	{
		posX = 1797.26,
		posY = 612.6,
		posZ = 46.67,
		aimX = 1721.25,
		aimY = 568.61,
		aimZ = 38.12, 
		reset = true
	},
	{
		posX = 1456.22,
		posY = 503.2,
		posZ = 32.32,
		aimX = 1382.97,
		aimY = 429.48,
		aimZ = 29.64,
		speed = 15000,
		wait = 500
	},
	{
		posX = 1665.58,
		posY = 837.97,
		posZ = 28.36,
		aimX = 1615.3,
		aimY = 865.32,
		aimZ = 21.72,
		reset = true
	},
	{
		posX = 1739.89,
		posY = 838.43,
		posZ = 31.35,
		aimX = 1794.67,
		aimY = 887.94,
		aimZ = 34.54,
		speed = 15000,
		wait = 500
	},
	{
		posX = -890.83,
		posY = 659.15,
		posZ = 108.86,
		aimX = -973.88,
		aimY = 715.54,
		aimZ = 105.18,
		reset = true
	},
	{
		posX = -1032.87,
		posY = 515.4,
		posZ = 108.14,
		aimX = -1144.52,
		aimY = 539.62,
		aimZ = 110.78,
		speed = 15000,
		wait = 500,
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