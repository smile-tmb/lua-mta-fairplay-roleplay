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

local shopWindow = {
	buttons = { },
	sections = { }
}
local shop

function getTabIndex( tab )
	if ( isElement( tab ) ) then
		local tabPanel = getElementParent( tab )

		for index, child in ipairs( getElementChildren( tabPanel ) ) do
			if ( tab == child ) then
				return index
			end
		end
	end

	return false
end

function showShopWindow( forceClose )
	if ( isElement( shopWindow.window ) ) then
		destroyElement( shopWindow.window );
		showCursor( false )

		if ( forceClose ) then
			return
		end
	end

	if ( not shop ) then
		return
	end

	showCursor( true )

	shopWindow.window = guiCreateWindow( ( screenWidth - xx ) / 2, ( screenHeight - xx ) / 2, xx, xx, shop.name, false )
	guiWindowSetSizable( shopWindow.window, false )

	local function purchaseItem( gridList, currentTab )
		if ( isElement( gridList ) ) then
			local row, column = guiGridListGetSelectedItem( gridList )

			if ( row ~= -1 ) and ( column ~= -1 ) then
				guiSetEnabled( shopWindow.window, false )
				triggerServerEvent( "shops:purchase", localPlayer, shop.id, getTabIndex( currentTab ), guiGridListGetItemText( gridList, row, 1 ) )
			else
				outputChatBox( "Please select a product from the list.", 230, 95, 95 )
			end
		end
	end

	for index, section in ipairs( shop.sections ) do
		shopWindow.sections[ index ] = { }
		shopWindow.sections[ index ].tab = guiCreateTab( section.name, shopWindow.tabPanel )
		shopWindow.sections[ index ].gridlist = guiCreateGridList( 5, 5, 300, 300, false, shopWindow.sections[ index ].tab )

		guiGridListAddColumn( shopWindow.sections[ index ].gridlist, "Index", 0.1 )
		guiGridListAddColumn( shopWindow.sections[ index ].gridlist, "Name", 0.2 )
		guiGridListAddColumn( shopWindow.sections[ index ].gridlist, "Description", 0.35 )
		guiGridListAddColumn( shopWindow.sections[ index ].gridlist, "Price ($)", 0.2 )
		guiGridListAddColumn( shopWindow.sections[ index ].gridlist, "Item ID", 0.1 )

		for index, item in ipairs( section.items ) do
			local row = guiGridListAddRow( shopWindow.sections[ index ].gridlist )

			guiGridListSetItemText( shopWindow.sections[ index ].gridlist, row, 1, index, false, true )
			guiGridListSetItemText( shopWindow.sections[ index ].gridlist, row, 2, item.name, false, false )
			guiGridListSetItemText( shopWindow.sections[ index ].gridlist, row, 3, exports.items:getItemDescription( item.id ), false, false )
			guiGridListSetItemText( shopWindow.sections[ index ].gridlist, row, 4, "$" .. exports.common:formatMoney( item.price ), false, true )
			guiGridListSetItemText( shopWindow.sections[ index ].gridlist, row, 5, item.id, false, false )
		end

		addEventHandler( "onClientGUIDoubleClick", shopWindow.sections[ index ].gridlist,
			function( )
				purchaseItem( source, getElementParent( source ) )
			end, false
		)
	end

	addEventHandler( "onClientGUIClick", shopWindow.button.purchase,
		function( )
			local currentTab = guiGetSelectedTab( shopWindow.tabPanel )
			local gridList = getElementChildren( currentTab )[ 1 ]

			purchaseItem( gridList, currentTab )
		end, false
	)

	addEventHandler( "onClientGUIClick", shopWindow.button.close,
		function( )
			showShopWindow( true )
		end, false
	)
end

addEvent( "shops:open", true )
addEventHandler( "shops:open", root,
	function( shopData )
		shop = shopData

		showShopWindow( )
	end
)