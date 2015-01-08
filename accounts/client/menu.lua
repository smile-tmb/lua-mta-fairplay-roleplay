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
local client_menu = {
	button = { }
}


function showMenu( forceClose )
	if ( isElement( client_menu.window ) ) then
		destroyElement( client_menu.window )
	end
	
	showCursor( false )
	
	if ( forceClose ) then
		return
	end
	
	if ( exports.common:isPlayerPlaying( localPlayer ) ) then
		showCursor( true )
		
		client_menu.window = guiCreateWindow( ( screenWidth - 273 ) / 2, ( screenHeight - 310 ) / 2, 273, 310, "Menu", false )
		guiWindowSetSizable( client_menu.window, false )
		guiSetAlpha( client_menu.window, 0.8725 )
		
		client_menu.button.selection = guiCreateButton( 18, 41, 238, 31, "Character selection", false, client_menu.window )
		client_menu.button.logout = guiCreateButton( 18, 82, 238, 31, "Log out", false, client_menu.window )
		client_menu.button.close = guiCreateButton( 18, 123, 238, 31, "Close menu", false, client_menu.window )
		
		addEventHandler( "onClientGUIClick", client_menu.button.selection,
			function( )
				triggerServerEvent( "characters:selection", localPlayer )
			end, false
		)
		
		addEventHandler( "onClientGUIClick", client_menu.button.logout,
			function( )
				triggerServerEvent( "accounts:logout", localPlayer )
			end, false
		)
		
		addEventHandler( "onClientGUIClick", client_menu.button.close,
			function( )
				showMenu( true )
			end, false
		)
	end
end
addEvent( "accounts:show_menu", true )
addEventHandler( "accounts:show_menu", root, showMenu )

function closeMenu( )
	showMenu( true )
end
addEvent( "accounts:close_menu", true )
addEventHandler( "accounts:close_menu", root, closeMenu )

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		bindKey( "F10", "down", showMenu )
	end
)