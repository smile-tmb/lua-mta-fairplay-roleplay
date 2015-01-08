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

function getFactions( )
	local factions = { }
	
	for _, team in ipairs( getElementsByType( "team" ) ) do
		if ( exports.factions:getFactionID( team ) ) then
			table.insert( factions, team )
		end
	end
	
	return factions
end

function getFactionByID( id )
	for _, faction in ipairs( getFactions( ) ) do
		if ( exports.factions:getFactionID( faction ) == id ) then
			return faction
		end
	end
	
	return false
end

function getFactionByName( name )
	for _, faction in ipairs( getFactions( ) ) do
		if ( exports.factions:getFactionName( faction ) == name ) then
			return faction
		end
	end
	
	return false
end

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		local civilians = createTeam( "Civilian", 255, 255, 255 )
	end
)