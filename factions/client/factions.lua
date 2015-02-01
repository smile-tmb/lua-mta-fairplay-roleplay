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
local factionSelector = {
	button = { }
}

local factions = { }

function showFactionMenu( forceClose )
	--todo
end

function getFactionByID( id )
	for index, faction in pairs( factions ) do
		if ( faction.id == id ) then
			return faction, index
		end
	end
	
	return false
end

function showFactionSelector( forceClose )
	if ( isElement( factionSelector.window ) ) then
		destroyElement( factionSelector.window )
		showCursor( false )
		
		if ( forceClose ) then
			return
		end
	end
	
	if ( not exports.common:isPlayerPlaying( localPlayer ) ) then
		return
	end
	
	showCursor( true )
	
	factionSelector.window = guiCreateWindow( ( screenWidth - 412 ) / 2, ( screenHeight - 392 ) / 2, 412, 392, "Factions", false )
	guiWindowSetSizable( factionSelector.window, false )

	factionSelector.factions = guiCreateGridList( 10, 28, 392, 235, false, factionSelector.window )
	guiGridListAddColumn( factionSelector.factions, "ID", 0.1 )
	guiGridListAddColumn( factionSelector.factions, "Name", 0.6 )
	guiGridListAddColumn( factionSelector.factions, "Type", 0.25 )
	
	local defaultFaction = exports.common:getPlayerDefaultFaction( localPlayer )
	
	if ( defaultFaction > 0 ) then
		local row = guiGridListAddRow( factionSelector.factions )
		
		guiGridListSetItemText( factionSelector.factions, row, 2, "Default faction", true, false )
		
		local faction = getFactionByID( defaultFaction )
		local row = guiGridListAddRow( factionSelector.factions )
		
		guiGridListSetItemText( factionSelector.factions, row, 1, faction.id, false, true )
		guiGridListSetItemText( factionSelector.factions, row, 2, faction.name, false, false )
		guiGridListSetItemText( factionSelector.factions, row, 3, getFactionType( faction.type ), false, false )
		
		if ( exports.common:count( factions ) > 1 ) then
			local row = guiGridListAddRow( factionSelector.factions )
			
			guiGridListSetItemText( factionSelector.factions, row, 2, "Alternate factions", true, false )
		end
	end
	
	for _, faction in pairs( factions ) do
		if ( defaultFaction ~= faction.id ) then
			local row = guiGridListAddRow( factionSelector.factions )
			
			guiGridListSetItemText( factionSelector.factions, row, 1, faction.id, false, true )
			guiGridListSetItemText( factionSelector.factions, row, 2, faction.name, false, false )
			guiGridListSetItemText( factionSelector.factions, row, 3, getFactionType( faction.type ), false, false )
		end
	end
	
	factionSelector.button.open = guiCreateButton( 10, 273, 392, 29, "Open faction panel", false, factionSelector.window )
	factionSelector.button.set = guiCreateButton( 10, 312, 392, 29, "Set as main faction", false, factionSelector.window )
	factionSelector.button.close = guiCreateButton( 10, 351, 392, 29, "Close window", false, factionSelector.window )
	
	local function openFactionMenu( )
		local row, column = guiGridListGetSelectedItem( factionSelector.factions )
		if ( row ~= -1 ) and ( column ~= -1 ) then
			local factionID = guiGridListGetItemText( factionSelector.factions, row, 1 )
				  factionID = tonumber( factionID ) or false
			
			if ( factionID ) then
				showFactionMenu( factionID )
			else
				outputChatBox( "Please select a faction from the list.", 230, 95, 95 )
			end
		else
			outputChatBox( "Please select a faction from the list.", 230, 95, 95 )
		end
	end
	addEventHandler( "onClientGUIDoubleClick", factionSelector.factions, openFactionMenu )
	addEventHandler( "onClientGUIClick", factionSelector.button.open, openFactionMenu )
	
	addEventHandler( "onClientGUIClick", factionSelector.button.set,
		function( )
			local row, column = guiGridListGetSelectedItem( factionSelector.factions )
			if ( row ~= -1 ) and ( column ~= -1 ) then
				local factionID = guiGridListGetItemText( factionSelector.factions, row, 1 )
					  factionID = tonumber( factionID ) or false
				
				if ( factionID ) then
					triggerServerEvent( "factions:set_as_main", localPlayer, factionID )
				else
					outputChatBox( "Please select a faction from the list.", 230, 95, 95 )
				end
			else
				outputChatBox( "Please select a faction from the list.", 230, 95, 95 )
			end
		end, false
	)
	
	addEventHandler( "onClientGUIClick", factionSelector.button.close,
		function( )
			showFactionSelector( true )
		end, false
	)
end

addEvent( "factions:update", true )
addEventHandler( "factions:update", root,
	function( serverFaction )
		local faction, index = getFactionByID( serverFaction.id )
		
		if ( faction ) then
			factions[ index ] = serverFaction
		else
			table.insert( factions, serverFaction )
		end
		
		if ( isElement( factionSelector.window ) ) then
			showFactionSelector( )
		end
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		bindKey( "F3", "down",
			function( )
				showFactionSelector( true )
			end
		)
	end
)