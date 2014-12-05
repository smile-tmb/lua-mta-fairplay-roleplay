local _addCommandHandler = addCommandHandler
function addCommandHandler( commandName, handlerFunction, caseSensitive )
	if ( type( commandName ) ~= "table" ) then
		commandName = { commandName }
	end
	
	for key, value in ipairs( commandName ) do
		_addCommandHandler( value, handlerFunction, caseSensitive )
	end
end