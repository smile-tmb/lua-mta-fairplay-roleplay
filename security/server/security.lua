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

local cleanedFunctions = { setElementData = setElementData, getElementData = getElementData, removeElementData = removeElementData }
local keyCharsLength = 64
local serverKey = ""

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
			
			local keyString = exports.common:getRandomString( keyCharsLength )
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
	end
)