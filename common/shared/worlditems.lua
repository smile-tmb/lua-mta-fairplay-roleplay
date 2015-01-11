function getWorldItemID( element )
	if ( not isElement( element ) ) or ( getElementType( element ) ~= "object" ) or ( not getElementData( element, "worlditem:id" ) ) then
		return false
	end
	
	return tonumber( getElementData( element, "worlditem:id" ) )
end

function isWorldItem( element )
	if ( not isElement( element ) ) or ( getElementType( element ) ~= "object" ) or ( not getElementData( element, "worlditem:id" ) ) then
		return false
	end
	
	return true
end