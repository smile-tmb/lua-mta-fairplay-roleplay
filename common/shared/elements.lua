function getNearbyElementsByType( x, y, z, type, distance )
	local elements = { }
	
	for _, element in ipairs( getElementsByType( type ) ) do
		if ( getDistanceBetweenPoints3D( x, y, z, getElementPosition( element ) ) < distance ) then
			table.insert( elements, element )
		end
	end
	
	return elements
end