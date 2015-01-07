local items = { }

function getItems( element )
	return items[ element ] or { }
end

function hasItem( element, itemID, itemValue )
	for index, values in ipairs( getItems( element ) ) do
		if ( values.itemID == itemID ) and ( ( not itemValue ) or ( values.itemValue == itemValue ) ) then
			return true, index, values
		end
	end
	
	return false
end

addEvent( "items:update", true )
addEventHandler( "items:update", root,
	function( sourceItems )
		items[ source ] = sourceItems
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		if ( exports.common:isPlayerPlaying( localPlayer ) ) then
			triggerServerEvent( "items:get", localPlayer )
		end
	end
)