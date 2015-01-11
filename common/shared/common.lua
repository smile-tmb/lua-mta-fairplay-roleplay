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

keyChars = { { 48, 57 }, { 65, 90 }, { 97, 122 } }
pedModels = {
	female = {
		white = { 12, 31, 38, 39, 40, 41, 53, 54, 55, 56, 64, 75, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 140, 145, 150, 151, 152, 157, 172, 178, 192, 193, 194, 196, 197, 198, 199, 201, 205, 211, 214, 216, 224, 225, 226, 231, 232, 233, 237, 243, 246, 251, 257, 263 },
		black = { 9, 10, 11, 12, 13, 40, 41, 63, 64, 69, 76, 91, 139, 148, 190, 195, 207, 215, 218, 219, 238, 243, 244, 245, 256 },
		asian = { 38, 53, 54, 55, 56, 88, 141, 169, 178, 224, 225, 226, 263 }
	},
	male = {
		white = { 23, 26, 27, 29, 30, 32, 33, 34, 35, 36, 37, 38, 43, 44, 45, 46, 47, 48, 50, 51, 52, 53, 58, 59, 60, 61, 62, 68, 70, 72, 73, 78, 81, 82, 94, 95, 96, 97, 98, 99, 100, 101, 108, 109, 110, 111, 112, 113, 114, 115, 116, 120, 121, 122, 124, 125, 126, 127, 128, 132, 133, 135, 137, 146, 147, 153, 154, 155, 158, 159, 160, 161, 162, 164, 165, 170, 171, 173, 174, 175, 177, 179, 181, 184, 186, 187, 188, 189, 200, 202, 204, 206, 209, 212, 213, 217, 223, 230, 234, 235, 236, 240, 241, 242, 247, 248, 250, 252, 254, 255, 258, 259, 261, 264 },
		black = { 7, 14, 15, 16, 17, 18, 20, 21, 22, 24, 25, 28, 35, 36, 50, 51, 66, 67, 78, 79, 80, 83, 84, 102, 103, 104, 105, 106, 107, 134, 136, 142, 143, 144, 156, 163, 166, 168, 176, 180, 182, 183, 185, 220, 221, 222, 249, 253, 260, 262 },
		asian = { 49, 57, 58, 59, 60, 117, 118, 120, 121, 122, 123, 170, 186, 187, 203, 210, 227, 228, 229 }
	}
}

function cleanString( string )
	while ( string:find( "  " ) ) do
		string:gsub( "  ", " " )
	end
	
	return string
end

function count( table )
	local count = 0
	
	for _ in pairs( table ) do
		count = count + 1
	end
	
	return count
end

function findByValue( _table, value, multiple, strict )
	local result = { }
	
	for k, v in pairs( _table ) do
		if ( type( v ) == "table" ) then
			for _k, _v in pairs( v ) do
				if ( _v == value ) and ( ( not strict ) or ( ( strict ) and ( type( _v ) == type( value ) ) ) ) then
					if ( multiple ) then
						table.insert( result, k )
					else
						return k
					end
				end
			end
		else
			if ( v == value ) and ( ( not strict ) or ( ( strict ) and ( type( v ) == type( value ) ) ) ) then
				if ( multiple ) then
					table.insert( result, k )
				else
					return k
				end
			end
		end
	end

	return result
end

function formatDate( string, preparedString )
	local dateAndTime = split( string, " " )
	local date = split( dateAndTime[ 1 ], "-" )
	local time = split( dateAndTime[ 2 ], ":" )

	local thExtension = { "st", "nd", "rd" }
	local day = date[ 3 ]:len( ) >= 2 and date[ 3 ]:sub( 2, 2 ) or date[ 3 ]
		  day = tonumber( day )
		  day = date[ 3 ] .. ( thExtension[ day ] or "th" )
		  day = day:sub( 1, 1 ) == "0" and day:sub( 2 ) or day

	local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
	local month = months[ tonumber( date[ 2 ] ) ]
	
	return preparedString and day .. " of " .. month .. " " .. date[ 1 ] .. " " .. dateAndTime[ 2 ] or { day = day, month = month, year = date[ 1 ], hour = time[ 1 ], minute = time[ 2 ], second = time[ 3 ] }
end

function formatString( string )
	return howToWrite( string ) and string .. "'" or string .. "'s"
end

function getDaysInMonth( month, year )
	return month == 2 and isLeapYear( year ) and 29 or ( "\31\28\31\30\31\30\31\31\30\31\30\31" ):byte( month )
end

function getRandomString( length )
	local buffer = ""
	
	for i = 0, length do
		math.randomseed( getTickCount( ) .. i .. i .. math.random( 123, 789 ) )
		
		local chars = keyChars[ math.random( #keyChars ) ]
		
		buffer = buffer .. string.char( math.random( chars[ 1 ], chars[ 2 ] ) )
	end
	
	return buffer
end

function getSplitValues( string )
	return split( string, ";_;" )
end

function getValidPedModelsByGenderAndColor( gender, color )
	local gender, color = gender:lower( ), color:lower( )
	return pedModels[ gender ] and pedModels[ gender ][ color ] or { }
end

function howToWrite( string )
	local selectorLetters = { s = true }
	local lastLetter = string:sub( #string, #string )
	
	if ( selectorLetters[ lastLetter ] ) then
		return true
	end
	
	return false
end

function isLeapYear( year )
	return ( year % 4 == 0 ) and ( year % 100 ~= 0 or year % 400 == 0 )
end

function nextIndex( table )
	local index = 1

	while ( true ) do
		if ( not table[ index ] ) then
			return index
		else
			index = index + 1
		end
	end
end

function nextToPosition( x, y, z, rotation, radius )
	rotation = rotation or 0
	radius = radius or 5
	
	if ( isElement( x ) ) then
		if ( y ) then
			radius = y
		end
		
		_, _, rotation = getElementRotation( x )
		x, y, z = getElementPosition( x )
	end
	
	x = x + ( ( math.cos( math.rad( rotation ) ) ) * radius )
	y = y + ( ( math.sin( math.rad( rotation ) ) ) * radius )
	
	return x, y, z
end