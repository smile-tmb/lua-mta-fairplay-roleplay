local messages = { }

function createMessage( player, message, messageType, messageGlobalID, hideButton, disableInput )
	triggerClientEvent( player, "messages:create", player, message, messageType, messageGlobalID, hideButton, disableInput )
end

function destroyMessage( player, messageType, messageGlobalID )
	triggerClientEvent( player, "messages:destroy", player, messageType, messageGlobalID )
end

function createGlobalMessage( message, messageType, hideButton, disableInput )
	local messageGlobalID = exports.common:nextIndex( messages )

	messages[ messageGlobalID ] = { message = message, messageType = messageType, hideButton = hideButton, disableInput = disableInput }

	for _, player in ipairs( getElementsByType( "player" ) ) do
		createMessage( player, message, messageType, messageGlobalID, hideButton, disableInput )
	end
end

function destroyGlobalMessage( messageGlobalID )
	if ( messages[ messageGlobalID ] ) then
		messages[ messageGlobalID ] = nil

		for _, player in ipairs( getElementsByType( "player" ) ) do
			destroyMessage( player, nil, messageGlobalID )
		end
	end
end

addEvent( "messages:ready", true )
addEventHandler( "messages:ready", root,
	function( )
		if ( source ~= client ) then
			return
		end
		
		for index, message in pairs( messages ) do
			createMessage( client, message.message, message.messageType, index, message.hideButton, message.disableInput )
		end
	end
)