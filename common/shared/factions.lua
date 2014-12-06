function getFactionID( faction )
	local factionID = getElementData( faction, "faction:id" )
	
	return factionID and tonumber( factionID ) or false
end