local messages = { }
local screenWidth, screenHeight = guiGetScreenSize( )
local messageWidth, messageHeight = 316, 152

function count( _table )
	local count = 0
	
	for _ in pairs( _table ) do
		count = count + 1
	end
	
	return count
end

function createMessage( message, type, hideButton )
	destroyMessage( type )
	
	local messageID = count( messages ) + 1
	
	messages[ messageID ] = { }
	
	local messageHeight = messageHeight - ( hideButton and 25 or 0 )
	
	messages[ messageID ].window = guiCreateWindow( ( screenWidth - messageWidth ) / 2, ( screenHeight - messageHeight ) / 2, messageWidth, messageHeight, "Message", false )
	guiWindowSetSizable( messages[ messageID ].window, false )
	guiSetProperty( messages[ messageID ].window, "AlwaysOnTop", "True" )
	guiSetAlpha( messages[ messageID ].window, 0.925 )
	
	setElementData( messages[ messageID ].window, "messages:id", messageID, false )
	setElementData( messages[ messageID ].window, "messages:type", type or "other", false )
	
	messages[ messageID ].message = guiCreateLabel( 17, 35, 283, 60, message, false, messages[ messageID ].window )
	guiLabelSetHorizontalAlign( messages[ messageID ].message, "center", true )
	guiLabelSetVerticalAlign( messages[ messageID ].message, "center" )
	
	if ( not hideButton ) then
		messages[ messageID ].button = guiCreateButton( 16, 109, 284, 25, "Continue", false, messages[ messageID ].window )	
		
		addEventHandler( "onClientGUIClick", messages[ messageID ].button,
			function( )
				local parent = getElementParent( source )
				local id = tonumber( getElementData( parent, "messages:id" ) )
				
				destroyElement( getElementParent( source ) )
				messages[ id ] = nil
				
				showCursor( false )
				
				triggerEvent( "accounts:enableGUI", localPlayer )
			end, false
		)
	end
	
	messages[ messageID ].type = type or "other"
end
addEvent( "messages:create", true )
addEventHandler( "messages:create", root, createMessage )

function destroyMessage( type )
	for index, message in pairs( messages ) do
		if ( message.type == type ) then
			if ( isElement( message.window ) ) then
				destroyElement( message.window )
			end
			
			message[ index ] = nil
		end
	end
end

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