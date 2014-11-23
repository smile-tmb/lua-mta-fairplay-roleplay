local networkDataKey = ""

local cleanedFunctions = { teaEncode = teaEncode, teaDecode = teaDecode }

function encryptNetworkData( data )
	local buffer = ""
	
	for i = 0, #data do
		local randoms = { "A", "B", "C", "D", "E", "F" }
		local randomNumber = math.random( 1, 6 )
		
		buffer = buffer .. randoms[ randomNumber ] .. data:sub( i ):byte( ) .. ( i < #data and "_" or "" )
	end
	
	return cleanedFunctions.teaEncode( buffer, networkDataKey ), networkDataKey
end

function decryptNetworkData( data )
	local buffer = ""
	
	local data = type( data ) == "table" and table.concat( data ) or data
		  data = cleanedFunctions.teaDecode( data, networkDataKey )
	
	data = split( data, "_" )
	
	for _, v in pairs( data ) do
		v = v:sub( 2, #v )
		
		if ( tonumber( v ) ) then
			buffer = buffer .. string.char( tonumber( v ) )
		end
	end
	
	return buffer:sub( 2 )
end

function batchNetworkData( data )
	local dataLength = #data
	local dataBuffer = { }
	
	local bufferSection = 1
	
	for i = 1, dataLength do
		if ( i % 4 == 0 ) then
			bufferSection = bufferSection + 1
		end
		
		dataBuffer[ bufferSection ] = ( dataBuffer[ bufferSection ] and dataBuffer[ bufferSection ] or "" ) .. data:sub( i, i )
	end
	
	return dataBuffer
end

addEvent( "security:setKey", true )
addEventHandler( "security:setKey", root,
	function( keyContainer, plainText )
		local key = type( keyContainer ) == "table" and table.concat( keyContainer, "" ) or keyContainer
		
		networkDataKey = plainText and key or decryptNetworkData( key )
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		triggerServerEvent( "security:ready", localPlayer )
	end
)