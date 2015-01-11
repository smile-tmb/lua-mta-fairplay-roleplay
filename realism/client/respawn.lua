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

local screenWidth, screenHeight = guiGetScreenSize( )
local selectedRespawnOption

local options = {
    button = { }
}

function optionsWindow( forceEnd )
	if ( isElement( options.window ) ) then
		destroyElement( options.window )
	end
	
	showCursor( false, false )
	
	if ( forceEnd ) then
		return
	end
	
	showCursor( true, true )
	
	options.window = guiCreateWindow( ( screenWidth - 276 ) / 2, ( screenHeight - 142 ) / 2, 276, 142, "Respawn options", false )
	guiWindowSetSizable( options.window, false )
	
	options.button[ 1 ] = guiCreateButton( 10, 28, 256, 27, "Respawn (PK)", false, options.window )
	options.button[ 2 ] = guiCreateButton( 10, 65, 256, 27, "Permanent death (CK)", false, options.window )
	options.button[ 3 ] = guiCreateButton( 10, 102, 256, 27, "Contact admin (DK)", false, options.window )
	
	for index in ipairs( options.button ) do
		addEventHandler( "onClientGUIClick", options.button[ index ],
			function( )
				selectedRespawnOption = index
				detailsWindow( )
			end, false
		)
	end
end

function showDeathScene( )
	if ( not exports.common:isOnDuty( localPlayer ) ) then
		optionsWindow( )
		
		local x, y, z = getElementPosition( localPlayer )
		
		setCameraMatrix( x, y, z + 3, x, y, z, getPedRotation( localPlayer ), 110 )
		
		triggerEvent( "inventory:close", localPlayer )
	end
end
addEventHandler( "onClientPlayerWasted", localPlayer, showDeathScene )
addEvent( "realism:death_scene", true )
addEventHandler( "realism:death_scene", root, showDeathScene )

addEvent( "realism:hide_death_scene", true )
addEventHandler( "realism:hide_death_scene", root,
	function( )
		optionsWindow( true )
		detailsWindow( true )
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		if ( not getElementData( localPlayer, "player:waiting" ) ) and ( isPedDead( localPlayer ) ) and ( exports.common:isPlayerPlaying( localPlayer ) ) then
			showDeathScene( )
		end
	end
)

addEvent( "accounts:showCharacterSelection", true )
addEventHandler( "accounts:showCharacterSelection", root,
	function( )
		triggerEvent( "realism:hide_death_scene", localPlayer )
	end
)

local details = {
	button = { },
	text = {
		{
			title = "Respawn (PK)",
			label = "Explain the cause of respawn and injuries:",
			complete = "Respawn"
		},
		{
			title = "Permanent death (CK)",
			label = "Cause of death:",
			complete = "Die"
		},
		{
			title = "Contact admin (DK)",
			label = "Explain why this death requires admin attention:",
			complete = "Request help"
		}
	}
}

function detailsWindow( forceEnd )
	if ( isElement( details.window ) ) then
		destroyElement( details.window )
	end
	
	if ( isElement( options.window ) ) then
		guiSetEnabled( options.window, true )
		guiSetVisible( options.window, true )
	end
	
	if ( forceEnd ) or ( not selectedRespawnOption ) then
		return
	end
	
	if ( isElement( options.window ) ) then
		guiSetEnabled( options.window, false )
		guiSetVisible( options.window, false )
	end
	
	details.window = guiCreateWindow( 636, 389, 320, 218, details.text[ selectedRespawnOption ].title, false )
	guiWindowSetSizable( details.window, false )
	
	details.info = guiCreateLabel( 11, 28, 299, 16, details.text[ selectedRespawnOption ].label, false, details.window )
	guiSetFont( details.info, "default-bold-small" )
	
	details.memo = guiCreateMemo( 10, 54, 300, 76, "", false, details.window )
	
	details.button.complete = guiCreateButton( 10, 140, 300, 27, details.text[ selectedRespawnOption ].complete, false, details.window )
	details.button.back = guiCreateButton( 10, 177, 300, 27, "Return", false, details.window )
	
	addEventHandler( "onClientGUIClick", details.button.complete,
		function( )
			local cleanDetails = guiGetText( details.memo )
			
			while ( cleanDetails:find( "  " ) ) do
				cleanDetails = cleanDetails:gsub( "  ", " " )
			end
			
			guiSetText( details.memo, cleanDetails )
			
			if ( cleanDetails:gsub( " ", "" ):len( ) >= 10 ) then
				triggerServerEvent( "realism:respawn", localPlayer, cleanDetails, selectedRespawnOption )
				
				detailsWindow( true )
				optionsWindow( true )
			else
				outputChatBox( "Please input information to the text field before submitting it.", 255, 0, 0, false )
			end
		end, false
	)
	
	addEventHandler( "onClientGUIClick", details.button.back,
		function( )
			detailsWindow( true )
		end, false
	)
end