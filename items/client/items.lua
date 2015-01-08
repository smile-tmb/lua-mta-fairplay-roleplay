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

local items = { }

function getItems( element )
	return items[ element ] or { }
end

function hasItem( element, itemID, itemValue )
	for index, values in ipairs( getItems( element ) ) do
		if ( values.itemID == itemID ) and ( ( not itemValue ) or ( values.itemValue == itemValue ) ) then
			return true, index, values
		end
	end
	
	return false
end

addEvent( "items:update", true )
addEventHandler( "items:update", root,
	function( sourceItems )
		items[ source ] = sourceItems
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		if ( exports.common:isPlayerPlaying( localPlayer ) ) then
			triggerServerEvent( "items:get", localPlayer )
		end
	end
)