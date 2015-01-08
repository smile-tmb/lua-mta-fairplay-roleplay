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
	
	return messageGlobalID
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

addEventHandler( "onResourceStop", root,
	function( resource )
		if ( getResourceName( resource ) == "vehicles" ) then
			for _, message in pairs( messages ) do
				if ( message.messageType == "vehicles-loading" ) then
					destroyGlobalMessage( message.messageGlobalID )
				end
			end
		end
	end
)