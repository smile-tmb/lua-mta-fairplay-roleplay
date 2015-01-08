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

bikes = { [ 581 ] = true, [ 509 ] = true, [ 481 ] = true, [ 462 ] = true, [ 521 ] = true, [ 463 ] = true, [ 510 ] = true, [ 522 ] = true, [ 461 ] = true, [ 448 ] = true, [ 468 ] = true, [ 586 ] = true, [ 536 ] = true, [ 575 ] = true, [ 567 ] = true, [ 480 ] = true, [ 555 ] = true }
windowless = { [ 568 ] = true, [ 601 ] = true, [ 424 ] = true, [ 457 ] = true, [ 480 ] = true, [ 485 ] = true, [ 486 ] = true, [ 528 ] = true, [ 530 ] = true, [ 531 ] = true, [ 532 ] = true, [ 571 ] = true, [ 572 ] = true }
roofless = { [ 568 ] = true, [ 500 ] = true, [ 439 ] = true, [ 424 ] = true, [ 457 ] = true, [ 480 ] = true, [ 485 ] = true, [ 486 ] = true, [ 530 ] = true, [ 531 ] = true, [ 533 ] = true, [ 536 ] = true, [ 555 ] = true, [ 571 ] = true, [ 572 ] = true, [ 575 ] = true }

function getBikeModels( )
	return bikes
end

function getWindowlessModels( )
	return windowless
end

function getRooflessModels( )
	return roofless
end

function isVehicleWindowsDown( vehicle )
	return getElementData( vehicle, "vehicle:windows" ) or false
end