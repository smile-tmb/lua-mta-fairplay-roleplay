local maintenanceStatus, overloadedStatus = false, false

function isServerInMaintenance( )
	return maintenanceStatus
end

function isServerOverloaded( )
	return overloadedStatus
end