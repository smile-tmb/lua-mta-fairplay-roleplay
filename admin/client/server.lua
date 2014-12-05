local maintenanceStatus, overloadedStatus = false, false

function isServerInMaintenance( )
	return maintenanceStatus
end

function isServerOverloaded( )
	return overloadedStatus
end

addEvent( "admin:update_server_status", true )
addEventHandler( "admin:update_server_status", root,
	function( maintenance, overloaded )
		maintenanceStatus = maintenance
		overloadedStatus = overloaded
		
		if ( maintenance ) then
			exports.messages:createMessage( "Server is currently in maintenance / about to restart. Use of some features is limited or slowed down to improve performance.", "server-maintenance" )
		end
		
		if ( overloaded ) then
			exports.messages:createMessage( "Server is currently under heavy load. Use of some features is limited or slowed down to improve performance.", "server-overloaded" )
		end
	end
)