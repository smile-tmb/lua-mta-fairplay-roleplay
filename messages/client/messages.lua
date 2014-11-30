local messages = { global = { }, client = { } }
local screenWidth, screenHeight = guiGetScreenSize( )
local messageWidth, messageHeight = 316, 152

function createMessage( message, messageType, messageGlobalID, hideButton, disableInput )
	destroyMessage( messageType )
	destroyMessage( nil, nil, messageGlobalID )

	local messageID = messageGlobalID or exports.common:nextIndex( messages )
	local messageRealm = messageGlobalID and "global" or "client"
	local messageHolder
	
	messages[ messageRealm ][ messageID ] = { messageType = messageType or "other", disableInput = disableInput }

	messageHolder = messages[ messageRealm ][ messageID ]
	
	local messageHeight = messageHeight - ( hideButton and 25 or 0 )
	
	messageHolder.window = guiCreateWindow( ( screenWidth - messageWidth ) / 2, ( screenHeight - messageHeight ) / 2, messageWidth, messageHeight, "Message", false )
	guiWindowSetSizable( messageHolder.window, false )
	guiSetProperty( messageHolder.window, "AlwaysOnTop", "True" )
	guiSetAlpha( messageHolder.window, 0.925 )
	
	setElementData( messageHolder.window, "messages:id", messageID, false )
	setElementData( messageHolder.window, "messages:type", messageHolder.messageType, false )
	setElementData( messageHolder.window, "messages:realm", messageRealm, false )
	setElementData( messageHolder.window, "messages:disableInput", disableInput, false )
	
	messageHolder.message = guiCreateLabel( 17, 35, 283, 60, message, false, messageHolder.window )
	guiLabelSetHorizontalAlign( messageHolder.message, "center", true )
	guiLabelSetVerticalAlign( messageHolder.message, "center" )

	if ( disableInput ) then
		guiSetInputEnabled( true )
	end
	
	if ( not hideButton ) then
		messageHolder.button = guiCreateButton( 16, 109, 284, 25, "Continue", false, messageHolder.window )	
		
		addEventHandler( "onClientGUIClick", messageHolder.button,
			function( )
				destroyMessage( messageHolder.messageType )
			end, false
		)
	end
end
addEvent( "messages:create", true )
addEventHandler( "messages:create", root, createMessage )

function destroyMessage( messageType, messageGlobalID )
	if ( messageType ) then
		for _, messageID in ipairs( exports.common:findByValue( messages.client, messageType, true ) ) do
			local message = messages.client[ messageID ]
			
			if ( isElement( message.window ) ) then
				destroyElement( message.window )
			end
			
			triggerEvent( "messages:onContinue", localPlayer, messageID, message.messageType, "client", message.disableInput )
			
			message = nil
		end
	else
		if ( messageGlobalID ) then
			local message = messages.global[ messageGlobalID ]

			if ( message ) then
				if ( isElement( message.window ) ) then
					destroyElement( message.window )
				end
				
				triggerEvent( "messages:onContinue", localPlayer, messageID, message.messageType, "global", message.disableInput )
				
				messages.global[ messageGlobalID ] = nil
			end
		end
	end
end
addEvent( "messages:destroy", true )
addEventHandler( "messages:destroy", root, destroyMessage )

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
		end
	end
)

addEventHandler( "onClientResourceStart", root,
	function( )
		triggerServerEvent( "messages:ready", localPlayer )
	end
)