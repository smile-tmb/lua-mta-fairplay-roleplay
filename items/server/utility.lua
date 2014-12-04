local _addCommandHandler = addCommandHandler
function addCommandHandler( commandName, handlerFunction, restricted, caseSensitive )
	if ( type( commandName ) ~= "table" ) then
		commandName = { commandName }
	end
	
	for key, value in ipairs( commandName ) do
		if ( key == 1 ) then
			_addCommandHandler( value, handlerFunction, restricted, caseSensitive )
		else
			_addCommandHandler( value,
				function( player, ... )
					if ( hasObjectPermissionTo( player, "command." .. commandName[ 1 ], not restricted ) ) then
						handlerFunction( player, ... )
					end
				end
			)
		end
	end
end