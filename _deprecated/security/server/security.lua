local keyChars = { { 48, 57 }, { 65, 90 }, { 97, 122 } }
local keyCharsLength = 64

local serverKey = ""

local networkDataKeys = { }
local networkDataCounter = 0
local networkDataCounterLimit = 5
local networkDataInterval = 0.5

local cleanedFunctions = { setElementData = setElementData, getElementData = getElementData, removeElementData = removeElementData, teaEncode = teaEncode, teaDecode = teaDecode, triggerClientEvent = triggerClientEvent, triggerEvent = triggerEvent }

function findByValue( _table, value )
	for i, v in pairs( _table ) do
		if ( v == value ) then
			return i
		end
	end
	
	return false
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

local function createServerKey( forceCreate )
	if ( not fileExists( "server.key" ) ) or ( forceCreate ) then
		if ( fileExists( "server.key" ) ) then
			fileRename( "server.key", "server-old-" .. getRealTime( ).timestamp .. ".key" )
		end
		
		local serverKeyFile = fileCreate( "server.key" )
		
		if ( serverKeyFile ) then
			math.randomseed( getTickCount( ) .. math.random( 123, 789 ) .. tostring( serverKeyFile ) )
			
			local networkData = getNetworkUsageData( )[ "out" ]
				  networkData = #networkData > 0 and networkData[ math.random( #networkData ) ] or hash( "md5", getTickCount( ) )
			
			local keyString = getRandomString( keyCharsLength )
				  keyString = hash( "sha512", keyString .. hash( "sha224", networkData .. getServerName( ) ) )
			
			fileWrite( serverKeyFile, keyString )
			fileClose( serverKeyFile )
			
			serverKey = keyString
			
			return true
		end
	end
	
	return false
end

local function getServerKey( minified )
	return not minified and serverKey or serverKey:sub( 5, 10 )
end

function hashString( string )
	outputConsole( string )
	return hash( "sha512", string .. getServerKey( ) )
end

local function getHashedDataKey( string )
	return hash( "md5", string .. getServerKey( true ) )
end

local function isDataSynchronized( element, key )
	return cleanedFunctions.getElementData( source, getHashedDataKey( key ) .. ":synchronized" )
end

local function isDataProtected( element, key )
	return cleanedFunctions.getElementData( source, getHashedDataKey( key ) .. ":protected" )
end

function modifyElementData( element, key, value, synchronized )
	if ( isElement( element ) ) then
		local hashedKey = getHashedDataKey( key )
		local clearElementData
		
		if ( value == nil ) then
			clearElementData = true
		end
		
		cleanedFunctions.setElementData( element, hashedKey .. ":protected", false, false )
		
		if ( clearElementData ) then
			cleanedFunctions.removeElementData( element, key )
			cleanedFunctions.removeElementData( element, hashedKey .. ":protected" )
			cleanedFunctions.removeElementData( element, hashedKey .. ":synchronized" )
		else
			cleanedFunctions.setElementData( element, key, value, synchronized )
			cleanedFunctions.setElementData( element, hashedKey .. ":synchronized", synchronized, false )
			cleanedFunctions.setElementData( element, hashedKey .. ":protected", true, false )
		end
		
		return true
	end
	
	return false
end

addEventHandler( "onElementDataChange", root,
	function( key, oldValue )
		local hashedKey = getHashedDataKey( key )
		
		if ( isDataProtected( source, key ) ) then
			local attemptedValue = cleanedFunctions.getElementData( source, key )
			
			modifyElementData( source, key, oldValue, isDataSynchronized( source, key ) )
			
			if ( client ) then
				outputServerLog( getPlayerName( client ) .. " tried to modify [" .. getElementType( source ) .. "]" .. ( getElementType( source ) == "player" and getPlayerName( source ) or "" ) .. " element data [key: " .. key .. "] [value: " .. attemptedValue .. "] [original: " .. oldValue .. "]. Reverted attempt." )
			end
		end
	end
)

local function generateNetworkDataKey( startup )
	if ( networkDataKeys[ 1 ] ) then
		networkDataKeys[ 2 ] = networkDataKeys[ 1 ]
	end
	
	networkDataKeys[ 1 ] = hash( "sha224", getRandomString( 12 ) .. getTickCount( ) )
	
	if ( not startup ) then
		for _, player in pairs( getElementsByType( "player" ) ) do
			cleanedFunctions.triggerClientEvent( player, "security:setKey", player, encryptNetworkData( networkDataKeys[ 1 ], true ) )
		end
	end
	
	outputServerLog( "SECURITY: New network key deployed." )
end

function encryptNetworkData( data, internal, dismissCount )
	if ( not internal ) then
		networkDataHandler( nil, nil, dismissCount )
	end
	
	local buffer = ""
	
	for i = 0, #data do
		local randoms = { "A", "B", "C", "D", "E", "F" }
		local randomNumber = math.random( 1, 6 )
		
		buffer = buffer .. randoms[ randomNumber ] .. data:sub( i ):byte( ) .. ( i < #data and "_" or "" )
	end
	
	local networkDataKey = networkDataKeys[ 1 ]
	
	return cleanedFunctions.teaEncode( buffer, networkDataKey ), networkDataKey
end

function decryptNetworkData( data, key, internal, dismissCount )
	if ( not internal ) then
		networkDataHandler( nil, nil, dismissCount )
	end
	
	local key = key or networkDataKeys[ 1 ]
	local index = findByValue( networkDataKeys, key )
	
	if ( index ) then
		local buffer = ""
		
		local data = type( data ) == "table" and table.concat( data ) or data
			  data = cleanedFunctions.teaDecode( data, key )
		
		data = split( data, "_" )
		
		for _, v in pairs( data ) do
			v = v:sub( 2, #v )
			
			if ( tonumber( v ) ) then
				buffer = buffer .. string.char( tonumber( v ) )
			end
		end
		
		return buffer:sub( 2 )
	end
	
	return false
end

function networkDataHandler( type, data, dismissCount )
	if ( not dismissCount ) then
		networkDataCounter = networkDataCounter + 1
	end
	
	local buffer
	
	if ( type ) and ( data ) then
		if ( type == "encrypt" ) then
			buffer = encryptNetworkData( data, true )
		elseif ( type == "decrypt" ) then
			buffer = decryptNetworkData( data, true )
		end
	end
	
	if ( networkDataCounter > networkDataCounterLimit ) then
		generateNetworkDataKey( )
		
		networkDataCounter = 0
	end
	
	return buffer
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

addEvent( "security:ready", true )
addEventHandler( "security:ready", root,
	function( )
		if ( source ~= client ) then
			return
		end
		
		--[[
		local encryptedData = encryptNetworkData( networkDataKeys[ 1 ], true )
		local encryptedDataLength = #encryptedData
		local encryptedBuffer = { }
		
		local bufferSection = 1
		
		for i = 1, encryptedDataLength do
			if ( i % 4 == 0 ) then
				bufferSection = bufferSection + 1
			end
			
			encryptedBuffer[ bufferSection ] = ""
			encryptedBuffer[ bufferSection ] = encryptedBuffer[ bufferSection ] .. encryptedData:sub( i, i )
		end
		]]
		
		cleanedFunctions.triggerClientEvent( client, "security:setKey", client, batchNetworkData( networkDataKeys[ 1 ] ), true )
	end
)

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		if ( not createServerKey( ) ) then
			if ( fileExists( "server.key" ) ) then
				local serverKeyFile = fileOpen( "server.key" )
				
				while ( not fileIsEOF( serverKeyFile ) ) do
					buffer = fileRead( serverKeyFile, 500 )
				end
				
				fileClose( serverKeyFile )
				
				serverKey = buffer
				
				outputServerLog( "SECURITY: Server private key fetched." )
			end
		else
			outputServerLog( "SECURITY: Server private key created." )
		end
		
		setTimer( function( )
			if ( #getElementsByType( "player" ) > 0 ) then
				generateNetworkDataKey( )
			end
		end, 1000 * 60 * networkDataInterval, 0 )
		
		generateNetworkDataKey( true )
	end
)