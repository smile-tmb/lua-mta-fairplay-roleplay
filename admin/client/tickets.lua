local screenWidth, screenHeight = guiGetScreenSize( )

local tickets = { }
local ticketSound
local activeTicket

function getTickets( )
	return tickets
end

addEvent( "admin:update_tickets", true )
addEventHandler( "admin:update_tickets", root,
	function( serverTickets, newTicket )
		tickets = serverTickets
		
		updateAdminHUD( )
		
		if ( newTicket ) then
			triggerEvent( "admin:new_ticket", localPlayer )
		end
		
		local found = false
		
		for id in pairs( getTickets( ) ) do
			if ( id == activeTicket ) then
				found = true
				break
			end
		end
		
		if ( not found ) then
			openTicket( nil, true )
		else
			openTicket( activeTicket )
		end
		
		updateTicketBrowser( )
	end
)

addEvent( "admin:new_ticket", true )
addEventHandler( "admin:new_ticket", root,
	function( )
		if ( isElement( ticketSound ) ) then
			destroyElement( ticketSound )
		end
		
		ticketSound = playSound( "sounds/admin_beep.mp3", false )
	end
)

function hideTicketUI( )
	closeTicketWindow( true )
	openTicket( nil, true )
	openTicketBrowser( true )
	createTicketWindow( true )
end
addEvent( "admin:hideHUD", true )
addEventHandler( "admin:hideHUD", root, hideTicketUI )
addEvent( "admin:hide_ticket_ui", true )
addEventHandler( "admin:hide_ticket_ui", root, hideTicketUI )
addEvent( "accounts:showCharacterSelection", true )
addEventHandler( "accounts:showCharacterSelection", root, hideTicketUI )

local ticketBrowser = {
    button = { }
}

function openTicketBrowser( forceEnd, stayClosed )
	if ( isElement( ticketBrowser.window ) ) then
		destroyElement( ticketBrowser.window )
		showCursor( false )
		
		if ( stayClosed ) then
			return
		end
	end
	
	if ( forceEnd ) then
		return
	end
	
	showCursor( true )
	
	ticketBrowser.window = guiCreateWindow( ( screenWidth - 563 ) / 2, ( screenHeight - 360 ) / 2, 563, 360, "Ticket Browser", false )
	guiWindowSetSizable( ticketBrowser.window, false )
	
	ticketBrowser.gridlist = guiCreateGridList( 10, 28, 543, 242, false, ticketBrowser.window )
	
	guiGridListAddColumn( ticketBrowser.gridlist, "ID", 0.1 )
	guiGridListAddColumn( ticketBrowser.gridlist, "Source", 0.25 )
	guiGridListAddColumn( ticketBrowser.gridlist, "Target", 0.25 )
	guiGridListAddColumn( ticketBrowser.gridlist, "Type", 0.35 )
	
	updateTicketBrowser( )
	
	ticketBrowser.button.open = guiCreateButton( 10, 280, 543, 28, "Open Ticket", false, ticketBrowser.window )
	ticketBrowser.button.close = guiCreateButton( 10, 318, 543, 28, "Close Browser", false, ticketBrowser.window )
	
	local function ticket( )
		local row, column = guiGridListGetSelectedItem( ticketBrowser.gridlist )
		
		if ( row ~= -1 ) and ( column ~= -1 ) then
			local id = tonumber( guiGridListGetItemText( ticketBrowser.gridlist, row, 1 ) )
			
			if ( getTickets( )[ id ] ) then
				openTicket( id )
			else
				outputChatBox( "This ticket does not exist anymore.", 230, 95, 95, false )
			end
		else
			outputChatBox( "Please select a ticket from the list.", 230, 95, 95, false )
		end
	end
	addEventHandler( "onClientGUIClick", ticketBrowser.button.open, ticket, false )
	addEventHandler( "onClientGUIDoubleClick", ticketBrowser.gridlist, ticket, false )
	
	addEventHandler( "onClientGUIClick", ticketBrowser.button.close,
		function( )
			openTicketBrowser( true )
		end, false
	)
end

function updateTicketBrowser( )
	if ( isElement( ticketBrowser.gridlist ) ) then
		guiGridListClear( ticketBrowser.gridlist )
		
		for id, ticket in pairs( getTickets( ) ) do
			local row = guiGridListAddRow( ticketBrowser.gridlist )
			
			guiGridListSetItemText( ticketBrowser.gridlist, row, 1, id, false, true )
			guiGridListSetItemText( ticketBrowser.gridlist, row, 2, ( ticket.sourcePlayer and isElement( ticket.sourcePlayer ) ) and exports.common:getPlayerName( ticket.sourcePlayer ) or tostring( ticket.sourcePlayer ) .. " (Offline)", false, false )
			guiGridListSetItemText( ticketBrowser.gridlist, row, 3, ( ticket.targetPlayer and isElement( ticket.targetPlayer ) ) and exports.common:getPlayerName( ticket.targetPlayer ) or tostring( ticket.targetPlayer ) .. " (Offline)", false, false )
			guiGridListSetItemText( ticketBrowser.gridlist, row, 4, ticketTypes[ ticket.type ], false, false )
		end
	end
end

local ticket = {
    button = { },
    label = { }
}

function openTicket( id, forceEnd )
	if ( isElement( ticket.window ) ) then
		destroyElement( ticket.window )
	end
	
	if ( isElement( ticketBrowser.window ) ) then
		guiSetEnabled( ticketBrowser.window, true )
		guiSetVisible( ticketBrowser.window, true )
	end
	
	activeTicket = nil
	
	if ( forceEnd ) then
		return
	end
	
	local thisTicket = getTickets( )[ id ]
	
	if ( not thisTicket ) then
		return false
	end
	
	activeTicket = id
	
	if ( isElement( ticketBrowser.window ) ) then
		guiSetEnabled( ticketBrowser.window, false )
		guiSetVisible( ticketBrowser.window, false )
	end
	
	ticket.window = guiCreateWindow( ( screenWidth - 719 ) / 2, ( screenHeight - 393 ) / 2, 719, 393, "Ticket", false )
	guiWindowSetSizable( ticket.window, false )
	guiSetAlpha( ticket.window, 0.9 )
	
	ticket.label[ 4 ] = guiCreateLabel( 10, 31, 96, 15, "ID:", false, ticket.window )
	ticket.label.id = guiCreateLabel( 116, 31, 205, 15, id, false, ticket.window )
	guiSetFont( ticket.label.id, "default-bold-small" )
	
	ticket.label[ 1 ] = guiCreateLabel( 10, 56, 96, 15, "Date and time:", false, ticket.window )
	ticket.label.date = guiCreateLabel( 116, 56, 205, 15, thisTicket.time or "N/A", false, ticket.window )
	guiSetFont( ticket.label.date, "default-bold-small" )
	
	ticket.label[ 8 ] = guiCreateLabel( 10, 81, 96, 15, "Submitter:", false, ticket.window )
	ticket.label.source = guiCreateLabel( 116, 81, 205, 15, ( thisTicket.sourcePlayer and isElement( thisTicket.sourcePlayer ) ) and exports.common:getPlayerName( thisTicket.sourcePlayer ) or tostring( thisTicket.sourcePlayer ) .. " (Offline)", false, ticket.window )
	guiSetFont( ticket.label.source, "default-bold-small" )
	
	ticket.label[ 5 ] = guiCreateLabel( 10, 106, 96, 15, "Reported player:", false, ticket.window )
	ticket.label.target = guiCreateLabel( 116, 106, 205, 15, ( thisTicket.targetPlayer and isElement( thisTicket.targetPlayer ) ) and ( thisTicket.targetPlayer == thisTicket.sourcePlayer and "-" or exports.common:getPlayerName( thisTicket.targetPlayer ) ) or tostring( thisTicket.targetPlayer ) .. " (Offline)", false, ticket.window )
	guiSetFont( ticket.label.target, "default-bold-small" )
	
	ticket.label[ 12 ] = guiCreateLabel( 10, 131, 96, 15, "Report type:", false, ticket.window )
	ticket.label.type = guiCreateLabel( 116, 131, 205, 15, ( thisTicket.type and ticketTypes[ thisTicket.type ] ) and ticketTypes[ thisTicket.type ] or "N/A", false, ticket.window )
	guiSetFont( ticket.label.type, "default-bold-small" )
	
	ticket.label[ 14 ] = guiCreateLabel( 10, 156, 96, 15, "Message:", false, ticket.window )
	ticket.message = guiCreateMemo( 116, 156, 340, 187, ( thisTicket.message and thisTicket.message ~= "" ) and thisTicket.message or "N/A", false, ticket.window )
	guiMemoSetReadOnly( ticket.message, true )
	
	ticket.label[ 9 ] = guiCreateLabel( 331, 31, 130, 15, "Place where reported:", false, ticket.window )
	ticket.label.location = guiCreateLabel( 471, 31, 238, 15, thisTicket.location or "N/A", false, ticket.window )
	guiSetFont( ticket.label.location, "default-bold-small" )
	guiLabelSetHorizontalAlign( ticket.label.location, "left", true )
	
	ticket.label[ 11 ] = guiCreateLabel( 331, 56, 130, 30, "Nearby players at the time of reporting:", false, ticket.window )
	guiLabelSetHorizontalAlign( ticket.label[ 11 ], "left", true )
	
	ticket.gridlist = guiCreateGridList( 471, 56, 238, 110, false, ticket.window )
	guiGridListAddColumn( ticket.gridlist, "Name", 0.4 )
	guiGridListAddColumn( ticket.gridlist, "Account", 0.3 )
	guiGridListAddColumn( ticket.gridlist, "Dist.", 0.2 )
	
	for _, data in ipairs( thisTicket.players ) do
		local row = guiGridListAddRow( ticket.gridlist )
		
		guiGridListSetItemText( ticket.gridlist, row, 1, data.name or "N/A", false, false )
		guiGridListSetItemText( ticket.gridlist, row, 2, data.account or "N/A", false, false )
		guiGridListSetItemText( ticket.gridlist, row, 3, data.distance .. " m" or "N/A", false, true )
	end
	
	ticket.button.goto_source = guiCreateButton( 471, 176, 238, 26, "Go to submitter", false, ticket.window )
	
	if ( thisTicket.sourcePlayer == localPlayer ) then
		guiSetEnabled( ticket.button.goto_source, false )
	end
	
	ticket.button.goto_target = guiCreateButton( 471, 212, 238, 26, "Go to reported player", false, ticket.window )
	
	if ( thisTicket.targetPlayer == localPlayer ) then
		guiSetEnabled( ticket.button.goto_target, false )
	end
	
	ticket.button.assign = guiCreateButton( 471, 248, 238, 26, "Assign ticket to yourself", false, ticket.window )
	ticket.button.close_spam = guiCreateButton( 471, 284, 238, 26, "Close ticket as spam", false, ticket.window )
	ticket.button.close = guiCreateButton( 471, 318, 238, 26, "Close ticket", false, ticket.window )
	
	if ( thisTicket.assignedTo > 0 ) then
		guiSetEnabled( ticket.button.assign, false )
		
		if ( thisTicket.assignedTo ~= exports.common:getAccountID( localPlayer ) ) then
			guiSetEnabled( ticket.button.close_spam, false )
			guiSetEnabled( ticket.button.close, false )
		end
	end
	
	ticket.button.close_window = guiCreateButton(471, 354, 238, 26, "Close window", false, ticket.window )
	guiSetFont( ticket.button.close_window, "default-bold-small" )
	
	addEventHandler( "onClientGUIClick", ticket.button.goto_source,
		function( )
			triggerServerEvent( "admin:goto_player", localPlayer, activeTicket, "source" )
		end, false
	)
	
	addEventHandler( "onClientGUIClick", ticket.button.goto_target,
		function( )
			triggerServerEvent( "admin:goto_player", localPlayer, activeTicket, "target" )
		end, false
	)
	
	addEventHandler( "onClientGUIClick", ticket.button.assign,
		function( )
			triggerServerEvent( "admin:ticket_assign", localPlayer, activeTicket )
		end, false
	)
	
	addEventHandler( "onClientGUIClick", ticket.button.close_spam,
		function( )
			triggerServerEvent( "admin:ticket_close", localPlayer, activeTicket, "Your ticket was closed as spam. Please refrain from creating spam tickets in the future or a punishment will be forced on your account.", true )
			openTicket( nil, true )
			openTicketBrowser( )
		end, false
	)
	
	addEventHandler( "onClientGUIClick", ticket.button.close,
		function( )
			closeTicketWindow( )
		end, false
	)
	
	addEventHandler( "onClientGUIClick", ticket.button.close_window,
		function( )
			openTicket( nil, true )
			openTicketBrowser( )
		end, false
	)
end

local closeTicket = {
	button = { }
}

function closeTicketWindow( forceEnd )
	if ( isElement( closeTicket.window ) ) then
		destroyElement( closeTicket.window )
	end
	
	if ( isElement( ticket.window ) ) then
		guiSetEnabled( ticket.window, true )
	end
	
	guiSetInputEnabled( false )
	
	if ( forceEnd ) then
		return
	end
	
	if ( isElement( ticket.window ) ) then
		guiSetEnabled( ticket.window, false )
	end
	
	guiSetInputEnabled( true )
	
	closeTicket.window = guiCreateWindow( 636, 389, 320, 218, "Close ticket", false )
	guiWindowSetSizable( closeTicket.window, false )
	
	closeTicket.info = guiCreateLabel( 11, 28, 299, 16, "Message (leave empty if none):", false, closeTicket.window )
	guiSetFont( closeTicket.info, "default-bold-small" )
	
	closeTicket.memo = guiCreateMemo( 10, 54, 300, 76, "", false, closeTicket.window )
	
	closeTicket.button.complete = guiCreateButton( 10, 140, 300, 27, "Close ticket", false, closeTicket.window )
	closeTicket.button.back = guiCreateButton( 10, 177, 300, 27, "Return", false, closeTicket.window )
	
	addEventHandler( "onClientGUIClick", closeTicket.button.complete,
		function( )
			local reason = guiGetText( closeTicket.memo )
			
			while ( reason:find( "  " ) ) do
				reason = reason:gsub( "  ", " " )
			end
			
			guiSetText( closeTicket.memo, reason )
			
			triggerServerEvent( "admin:ticket_close", localPlayer, activeTicket, reason:len( ) < 5 and "Thank you for your ticket, it has now been resolved. If you feel that this matter has not yet been resolved, feel free to file another ticket for review." or reason )
			
			closeTicketWindow( true )
			openTicket( nil, true )
			openTicketBrowser( )
		end, false
	)
	
	addEventHandler( "onClientGUIClick", closeTicket.button.back,
		function( )
			closeTicketWindow( true )
		end, false
	)
end

local newTicket = {
    label = { },
    button = { }
}

function createTicketWindow( forceEnd, stayClosed )
	if ( isElement( newTicket.window ) ) then
		destroyElement( newTicket.window )
		showCursor( false, false )
		
		if ( stayClosed ) then
			return
		end
	end
	
	if ( forceEnd ) then
		return
	end
	
	showCursor( true, true )
	
	newTicket.window = guiCreateWindow( 633, 353, 303, 394, "Create ticket", false )
	guiWindowSetSizable( newTicket.window, false )
	guiSetAlpha( newTicket.window, 0.9 )

	newTicket.label[ 1 ] = guiCreateLabel( 16, 32, 270, 15, "Ticket regarding", false, newTicket.window )
	newTicket.type = guiCreateComboBox( 16, 57, 270, 23, "", false, newTicket.window )
	
	for _, type in pairs( ticketTypes ) do
		guiComboBoxAddItem( newTicket.type, type )
	end
	
	guiComboBoxSetSelected( newTicket.type, 0 )
	guiSetSize( newTicket.type, guiGetSize( newTicket.type, false ), #ticketTypes * 20, false )
	
	newTicket.label[ 2 ] = guiCreateLabel( 16, 90, 270, 15, "Reported player (Self)", false, newTicket.window )
	newTicket.target = guiCreateEdit( 16, 115, 270, 25, getPlayerName( localPlayer ), false, newTicket.window )
	
	addEventHandler( "onClientGUIChanged", newTicket.target,
		function( )
			local player = exports.common:getPlayerFromPartialName( guiGetText( source ) )
			
			if ( player ) and ( player ~= localPlayer ) then
				guiSetText( newTicket.label[ 2 ], "Reported player (Found: " .. getPlayerName( player ) .. ")" )
			else
				guiSetText( newTicket.label[ 2 ], "Reported player (Self)" )
			end
		end
	)
	
	addEventHandler( "onClientGUIBlur", newTicket.target,
		function( )
			local player = exports.common:getPlayerFromPartialName( guiGetText( source ) )
			
			if ( player ) then
				guiSetText( source, getPlayerName( player ) )
			end
			
			if ( player == localPlayer ) or ( not player ) then
				guiSetText( newTicket.label[ 2 ], "Reported player (Self)" )
			end
		end
	)
	
	newTicket.label[ 3 ] = guiCreateLabel( 16, 150, 270, 15, "Message", false, newTicket.window )
	guiLabelSetColor( newTicket.label[ 3 ], 230, 95, 95 )
	newTicket.message = guiCreateMemo( 16, 175, 270, 135, "", false, newTicket.window )
	
	addEventHandler( "onClientGUIChanged", newTicket.message,
		function( )
			local message = guiGetText( newTicket.message )
			
			if ( message:len( ) < 15 ) or ( message:len( ) > 1000 ) then
				guiLabelSetColor( newTicket.label[ 3 ], 230, 95, 95 )
			elseif ( message:len( ) > 900 ) and ( message:len( ) <= 1000 ) then
				guiLabelSetColor( newTicket.label[ 3 ], 230, 180, 95 )
			else
				guiLabelSetColor( newTicket.label[ 3 ], 95, 230, 95 )
			end
		end
	)
	
	newTicket.button.submit = guiCreateButton( 16, 320, 270, 25, "Create ticket", false, newTicket.window )
	newTicket.button.close = guiCreateButton( 16, 355, 270, 25, "Close window", false, newTicket.window )
	
	addEventHandler( "onClientGUIClick", newTicket.button.submit,
		function( )
			local selectedType = guiComboBoxGetSelected( newTicket.type ) + 1
			
			if ( selectedType ) and ( selectedType > 0 ) then
				local targetName = guiGetText( newTicket.target )
				local message = guiGetText( newTicket.message )
				
				while ( targetName:find( "  " ) ) do
					targetName = targetName:gsub( "  ", " " )
				end
				
				targetName = targetName:gsub( " ", "_" )
				targetName = targetName:sub( #targetName ) == "_" and targetName:sub( 1, #targetName - 1 ) or targetName
				
				guiSetText( newTicket.target, targetName )
				
				while ( message:find( "  " ) ) do
					message = message:gsub( "  ", " " )
				end
				
				message = message:sub( #message ) == " " and message:sub( 1, #message - 1 ) or message
				
				guiSetText( newTicket.message, message )
				
				if ( message:len( ) >= 15 ) and ( message:len( ) <= 1000 ) then
					triggerServerEvent( "admin:new_ticket", localPlayer, targetName, message, selectedType )
				else
					outputChatBox( "Message length is not sufficient. Minimum length is 15 and maximum length is 1000 characters.", 230, 95, 95, false )
				end
			else
				outputChatBox( "Please select the ticket type.", 230, 95, 95, false )
			end
		end, false
	)
	
	addEventHandler( "onClientGUIClick", newTicket.button.close,
		function( )
			createTicketWindow( true )
		end, false
	)
end

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		bindKey( "F2", "down",
			function( )
				createTicketWindow( false, true )
			end
		)
	end
)