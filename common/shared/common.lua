keyChars = { { 48, 57 }, { 65, 90 }, { 97, 122 } }
pedModels = {
	female = {
		white = { 12, 31, 38, 39, 40, 41, 53, 54, 55, 56, 64, 75, 77, 85, 86, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 140, 145, 150, 151, 152, 157, 172, 178, 192, 193, 194, 196, 197, 198, 199, 201, 205, 211, 214, 216, 224, 225, 226, 231, 232, 233, 237, 243, 246, 251, 257, 263 },
		black = { 9, 10, 11, 12, 13, 40, 41, 63, 64, 69, 76, 91, 139, 148, 190, 195, 207, 215, 218, 219, 238, 243, 244, 245, 256 },
		asian = { 38, 53, 54, 55, 56, 88, 141, 169, 178, 224, 225, 226, 263 }
	},
	male = {
		white = { 23, 26, 27, 29, 30, 32, 33, 34, 35, 36, 37, 38, 43, 44, 45, 46, 47, 48, 50, 51, 52, 53, 58, 59, 60, 61, 62, 68, 70, 72, 73, 78, 81, 82, 94, 95, 96, 97, 98, 99, 100, 101, 108, 109, 110, 111, 112, 113, 114, 115, 116, 120, 121, 122, 124, 125, 126, 127, 128, 132, 133, 135, 137, 146, 147, 153, 154, 155, 158, 159, 160, 161, 162, 164, 165, 170, 171, 173, 174, 175, 177, 179, 181, 184, 186, 187, 188, 189, 200, 202, 204, 206, 209, 212, 213, 217, 223, 230, 234, 235, 236, 240, 241, 242, 247, 248, 250, 252, 254, 255, 258, 259, 261, 264 },
		black = { 7, 14, 15, 16, 17, 18, 20, 21, 22, 24, 25, 28, 35, 36, 50, 51, 66, 67, 78, 79, 80, 83, 84, 102, 103, 104, 105, 106, 107, 134, 136, 142, 143, 144, 156, 163, 166, 168, 176, 180, 182, 183, 185, 220, 221, 222, 249, 253, 260, 262 },
		asian = { 49, 57, 58, 59, 60, 117, 118, 120, 121, 122, 123, 170, 186, 187, 203, 210, 227, 228, 229 }
	}
}

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

function findByValue( table, value, multiple, strict )
	local result

	for k, v in pairs( table ) do
		if ( v == value ) and ( type( v ) == type( value ) ) then
			if ( multiple ) then
				table.insert( result, v )
			else
				return v
			end
		end
	end

	return result
end

function count( table )
	local count = 0
	
	for _ in pairs( table ) do
		count = count + 1
	end
	
	return count
end

function isLeapYear( year )
	return ( year % 4 == 0 ) and ( year % 100 ~= 0 or year % 400 == 0 )
end

function getDaysInMonth( month, year )
	return month == 2 and isLeapYear( year ) and 29 or ( "\31\28\31\30\31\30\31\31\30\31\30\31" ):byte( month )
end

function getValidPedModelsByGenderAndColor( gender, color )
	return pedModels[ gender ][ color ]
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