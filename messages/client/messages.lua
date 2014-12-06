local messages = { global = { }, client = { } }
local screenWidth, screenHeight = guiGetScreenSize( )
local messageWidth, messageHeight = 316, 152

function createMessage( message, messageType, messageGlobalID, hideButton, disableInput )
	destroyMessage( messageType )
	destroyMessage( nil, nil, messageGlobalID )

	local messageRealm = messageGlobalID and "global" or "client"
	local messageID = messageGlobalID or exports.common:nextIndex( messages[ messageRealm ] )
	
	messages[ messageRealm ][ messageID ] = { messageType = messageType or "other", disableInput = disableInput }
	
	local messageHeight = messageHeight - ( hideButton and 25 or 0 )
	
	messages[ messageRealm ][ messageID ].window = guiCreateWindow( ( screenWidth - messageWidth ) / 2, ( screenHeight - messageHeight ) / 2, messageWidth, messageHeight, "Message", false )
	guiWindowSetSizable( messages[ messageRealm ][ messageID ].window, false )
	guiSetProperty( messages[ messageRealm ][ messageID ].window, "AlwaysOnTop", "True" )
	guiSetAlpha( messages[ messageRealm ][ messageID ].window, 0.925 )
	
	setElementData( messages[ messageRealm ][ messageID ].window, "messages:id", messageID, false )
	setElementData( messages[ messageRealm ][ messageID ].window, "messages:type", messages[ messageRealm ][ messageID ].messageType, false )
	setElementData( messages[ messageRealm ][ messageID ].window, "messages:realm", messageRealm, false )
	setElementData( messages[ messageRealm ][ messageID ].window, "messages:disableInput", disableInput, false )
	
	if ( messageRealm == "global" ) then
		setElementData( messages[ messageRealm ][ messageID ].window, "messages:globalID", messageGlobalID, false )
	end
	
	messages[ messageRealm ][ messageID ].message = guiCreateLabel( 17, 35, 283, 60, message, false, messages[ messageRealm ][ messageID ].window )
	guiLabelSetHorizontalAlign( messages[ messageRealm ][ messageID ].message, "center", true )
	guiLabelSetVerticalAlign( messages[ messageRealm ][ messageID ].message, "center" )

	showCursor( true )
	guiSetInputEnabled( disableInput or false )
	
	if ( not hideButton ) then
		messages[ messageRealm ][ messageID ].button = guiCreateButton( 16, 109, 284, 25, "Continue", false, messages[ messageRealm ][ messageID ].window )	
		
		addEventHandler( "onClientGUIClick", messages[ messageRealm ][ messageID ].button,
			function( )
				local type = getElementData( getElementParent( source ), "messages:type" )
				local globalID = getElementData( getElementParent( source ), "messages:globalID" )
				
				destroyMessage( type, globalID or nil )
			end, false
		)
	end
end
addEvent( "messages:create", true )
addEventHandler( "messages:create", root, createMessage )

function destroyMessage( messageType, messageGlobalID )
	if ( not messageGlobalID ) then
		for index, data in pairs( messages.client ) do
			if ( data.messageType == messageType ) then
				if ( isElement( messages.client[ index ].window ) ) then
					destroyElement( messages.client[ index ].window )
				end
				
				triggerEvent( "messages:onContinue", localPlayer, index, data.messageType, "client", data.disableInput )
				
				messages.client[ index ] = nil
			end
		end
	else
		if ( messages.global[ messageGlobalID ] ) then
			if ( isElement( messages.global[ messageGlobalID ].window ) ) then
				destroyElement( messages.global[ messageGlobalID ].window )
			end
			
			triggerEvent( "messages:onContinue", localPlayer, messageID, messages.global[ messageGlobalID ].messageType, "global", messages.global[ messageGlobalID ].disableInput )
			
			messages.global[ messageGlobalID ] = nil
		end
	end
	
	if ( not isMessageOpen( ) ) then
		showCursor( false )
		guiSetInputEnabled( false )
	end
end
addEvent( "messages:destroy", true )
addEventHandler( "messages:destroy", root, destroyMessage )

function isMessageOpen( )
	if ( exports.common:count( messages.client ) > 0 ) or ( exports.common:count( messages.global ) > 0 ) then
		return true
	end
	
	return false
end

addEvent( "messages:onContinue", true )
addEventHandler( "messages:onContinue", root,
	function( id, type, realm, disableInput )
		if ( type == "login" ) then
			triggerEvent( "accounts:enableGUI", localPlayer )
		elseif ( type == "selection" ) then
			triggerEvent( "characters:enableGUI", localPlayer )
		end
	end
)

addEventHandler( "onClientResourceStop", root,
	function( resource )
		if ( not getElementData( localPlayer, "account:id" ) ) then
			triggerEvent( "accounts:enableGUI", localPlayer )
		end
		
		if ( getResourceName( resource ) == "accounts" ) then
			destroyMessage( "login" )
			destroyMessage( "selection" )
		end
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		triggerServerEvent( "messages:ready", localPlayer )
	end
)