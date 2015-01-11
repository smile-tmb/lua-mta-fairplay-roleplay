function getRealWorldItemID( element )
	if ( not isElement( element ) ) or ( getElementType( element ) ~= "object" ) or ( not getElementData( element, "worlditem:id" ) ) then
		return false
	end
	
	return tonumber( getElementData( element, "worlditem:id" ) )
end

function getWorldItemID( element )
	if ( not isElement( element ) ) or ( getElementType( element ) ~= "object" ) or ( not getElementData( element, "worlditem:item_id" ) ) then
		return false
	end
	
	return tonumber( getElementData( element, "worlditem:item_id" ) )
end

function getWorldItemValue( element )
	if ( not isElement( element ) ) or ( getElementType( element ) ~= "object" ) or ( not getElementData( element, "worlditem:item_value" ) ) then
		return false
	end
	
	return getElementData( element, "worlditem:item_value" )
end

function isWorldItem( element )
	if ( not isElement( element ) ) or ( getElementType( element ) ~= "object" ) or ( not getElementData( element, "worlditem:id" ) ) then
		return false
	end
	
	return true
end