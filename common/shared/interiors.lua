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

function getInteriorID( interior )
	return ( isElement( interior ) and getElementData( interior, "interior:id" ) ) and tonumber( getElementData( interior, "interior:id" ) ) or false
end

function getInteriorName( interior )
	return getElementData( interior, "interior:name" ) or false
end

function getInteriorOwner( interior, doNotAbsolutize )
	return ( isElement( interior ) and getElementData( interior, "interior:owner" ) ) and ( doNotAbsolutize and tonumber( getElementData( interior, "interior:owner" ) ) or math.abs( tonumber( getElementData( interior, "interior:owner" ) ) ) ) or false
end

function isFactionInterior( interior )
	local ownerID = getInteriorOwner( interior, true )
	return ownerID and ownerID < 0 or false
end