local screenWidth, screenHeight = guiGetScreenSize( )
local isInventoryVisible = false
local illegalDrop = { [ 9 ] = true }

local categories = { "backpack", "keys", "weapons" }
local items = { }

do
	for _, categoryName in ipairs( categories ) do
		items[ categoryName ] = { }
	end
end

local maximumIndex = 6
local inventoryCooldownTimer = false

local hoveringCategoryID
local inventoryOpenCategoryID

local localItemBackgroundCurrentIndex = 0
local localItemBackgroundCurrentRow = 1

local inventoryRowWidth = 282
local inventoryRowOffset = 100

local localItemScale = 90
local localItemMargin = 3
local currentLocalItemIndex = 0
local currentLocalItemRow = 1

local currentHoverItemIndex = 0
local currentHoverItemRow = 1
local hoveringItemIndex = 0
local deletingItemIndex = 0

local currentClickItemIndex = 0
local currentClickItemRow = 1

local collision, x, y, z, element
local _cursorX, _cursorY = 0, 0
local maxDistance = 6
local distance

local draggingItemSlot
local draggingIndex = 0
local draggingRow = 1
local isDeletingItem = false
local isDraggingWorldItem = false

local isInventoryLocked = false

local function doesContainData( case )
	if ( not items[ categories[ case ] ] ) or ( #items[ categories[ case ] ] == 0 ) then
		return false
	else
		return true
	end
end

local function isHoveringWorldItem( )
	local cursorX, cursorY, worldX, worldY, worldZ = getCursorPosition( )
		  cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
	local cameraX, cameraY, cameraZ = getWorldFromScreenPosition( cursorX, cursorY, 0.1 )
	local _, x, y, z, element = processLineOfSight( cameraX, cameraY, cameraZ, worldX, worldY, worldZ )
	
	if ( element ) and ( exports.items:isWorldItem( element ) ) then
		return element
	elseif ( x ) and ( y ) and ( z ) then
		local maxDistance = 0.34
		
		for _, object in ipairs( getElementsByType( "object" ) ) do
			if ( isElementStreamedIn( object ) ) and ( isElementOnScreen( object ) ) and ( exports.items:isWorldItem( object ) ) then
				local objectX, objectY, objectZ = getElementPosition( object )
				local distance = getDistanceBetweenPoints3D( objectX, objectY, objectZ, x, y, z )
				
				if ( distance < maxDistance ) then
					element = object
					maxDistance = distance
				end
			end
		end
		
		if ( element ) then
			local playerX, playerY, playerZ = getElementPosition( localPlayer )
			local objectX, objectY, objectZ = getElementPosition( element )
			
			return getDistanceBetweenPoints3D( playerX, playerY, playerZ, objectX, objectY, objectZ ) < maxDistance
		end
	end
end

addEventHandler( "onClientRender", root,
	function( )
		if ( isCursorShowing( ) ) then
			local cursorX, cursorY, worldX, worldY, worldZ = getCursorPosition( )
				  cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
			
			if ( isDraggingWorldItem ) then
				local itemID = tonumber( getElementData( isDraggingWorldItem, "worlditem:item_id" ) )
				local value = getElementData( isDraggingWorldItem, "worlditem:value" )
				local fileName = itemID
				local item = exports.items:getItem( itemID )
				
				if ( itemID == 11 ) then
					local weaponData = split( value, ";" )
					
					if ( #weaponData > 0 ) then
						fileName = fileName .. "_" .. weaponData[ 1 ]
					end
				end
				
				local playerX, playerY, playerZ = getElementPosition( localPlayer )
				local cameraX, cameraY, cameraZ = getWorldFromScreenPosition( cursorX, cursorY, 0.1 )
				collision, x, y, z, element = processLineOfSight( cameraX, cameraY, cameraZ, worldX, worldY, worldZ )
				distance = maxDistance
				
				if ( x ) and ( y ) and ( z ) then
					distance = getDistanceBetweenPoints3D( x, y, z, playerX, playerY, playerZ )
				end
				
				local color = tocolor( 0, 0, 0, 0.6 * 255 )
				
				if ( not collision ) or ( distance >= maxDistance ) then
					color = tocolor( 155, 25, 25, 0.7 * 255 )
				elseif ( isElement( element ) ) and ( getElementType( element ) == "player" ) then
					color = tocolor( 25, 155, 25, 0.7 * 255 )
				elseif ( isDeletingItem ) then
					color = tocolor( 105, 20, 20, 0.75 * 255 )
				end
				
				dxDrawRectangle( cursorX, cursorY, localItemScale, localItemScale, color, true )
				dxDrawImage( cursorX + ( localItemScale / 8 ) - 1, cursorY + ( localItemScale / 8 ) - 4, localItemScale - 18, localItemScale - 18, "images/" .. fileName .. ".png", 0, 0, 0, tocolor( 255, 255, 255, 0.95 * 255 ), true )
			else
				local element = isHoveringWorldItem( )
				
				if ( isElement( element ) ) and ( getElementType( element ) == "object" ) then
					local itemData = exports.items:isWorldItem( element )
					
					if ( itemData ) then
						local item = exports.items:getItem( itemData.item_id )
						local name = item.name
						local value = item.description
						local length = 200
						
						if ( inventoryOpenCategoryID == 2 ) then
							name = item.name .. " (" .. itemData.value .. ")"
							value = item.value
						else
							name = item.name
						end
						
						if ( not value ) or ( value == "" ) then
							value = item.description
						end
						
						if ( itemData.item_id == 10 ) then
							name = item.name .. " (#" .. itemData.value .. ")"
						elseif ( itemData.item_id == 11 ) then
							local parts = split( itemData.value, ";" )
							
							if ( #parts >= 2 ) and ( #parts <= 3 ) then
								name = parts[ 2 ]
								
								if ( #parts == 3 ) then
									value = parts[ 3 ]
								end
							else
								name = item.name
							end
						elseif ( itemData.item_id == 12 ) then
							local parts = split( itemData.value, ";" )
							
							if ( #parts >= 2 ) then
								name = name .. " (@" .. getWeaponNameFromID( parts[ 1 ] ) .. ") (" .. parts[ 2 ] .. " bullets)"
							else
								name = item.name
							end
						end
						
						local nameLength = math.max( 200, dxGetTextWidth( name ) * 1.5 )
						local valueLength = math.max( 200, dxGetTextWidth( value ) * 1.5 )
						
						if ( string.len( name ) > string.len( value ) ) then
							length = nameLength
						else
							length = valueLength
						end
						
						dxDrawRectangle( cursorX, cursorY, length, 57, tocolor( 0, 0, 0, 0.5 * 255 ), true )
						dxDrawText( name .. ( value == "" and "" or "\n" .. value ), cursorX + 17, cursorY + 15, length, 50, tocolor( 245, 245, 245, 255 ), 1.0, "clear", "left", "top", false, false, true, false, true )
					end
				end
			end
		end
		
		if ( not isInventoryVisible ) then
			return
		end
		
		-- Background
		dxDrawRectangle( ( screenWidth - inventoryRowWidth ) / 2, ( inventoryOpenCategoryID and screenHeight - inventoryRowOffset + 4 or screenHeight - inventoryRowOffset ), inventoryRowWidth, screenHeight, tocolor( 0, 0, 0, 0.65 * 255 ), true )
		dxDrawRectangle( ( screenWidth - inventoryRowWidth ) / 2, screenHeight - 2, inventoryRowWidth, screenHeight, tocolor( 245, 245, 245, 0.9 * 255 ), true )
		
		for categoryID = 0, #categories - 1 do
			dxDrawRectangle( ( screenWidth - inventoryRowWidth + ( localItemScale * 2 * categoryID ) ) / 2 + ( localItemMargin * ( categoryID + 1 ) ), screenHeight - ( inventoryRowOffset - 4 ), localItemScale, localItemScale, tocolor( 0, 0, 0, ( hoveringCategoryID == categoryID + 1 and 0.6 * 255 or 0.5 * 255 ) ), true )
			dxDrawImage( ( screenWidth - inventoryRowWidth + ( localItemScale * 2 * categoryID ) ) / 2 + ( localItemMargin * ( categoryID + 1 ) ), screenHeight - ( inventoryRowOffset - 4 ), localItemScale, localItemScale, "images/" .. categories[ categoryID + 1 ] .. ".png", 0, 0, 0, tocolor( 255, 255, 255, ( hoveringCategoryID == categoryID + 1 and 0.95 * 255 or 0.8 * 255 ) ), true )
		end
		
		local cursorX, cursorY, worldX, worldY, worldZ = getCursorPosition( )
		cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
		
		if ( inventoryOpenCategoryID ) then
			-- Background
			for localItemIndex, localItem in pairs( items[ categories[ inventoryOpenCategoryID ] ] ) do
				if ( localItemBackgroundCurrentIndex == maximumIndex ) then
					localItemBackgroundCurrentIndex = 0
					localItemBackgroundCurrentRow = localItemBackgroundCurrentRow + 1
				end
				
				if ( localItemIndex == #items[ categories[ inventoryOpenCategoryID ] ] ) then
					localItemBackgroundCurrentIndex = 0
					localItemBackgroundCurrentRow = 1
				end
				
				localItemBackgroundCurrentIndex = localItemBackgroundCurrentIndex + 1
				
				if ( localItemBackgroundCurrentIndex == 1 ) then
					dxDrawRectangle( ( screenWidth-inventoryRowWidth * 2 ) / 2, ( ( screenHeight - ( inventoryRowOffset * 2 ) ) - ( ( localItemScale + localItemMargin ) * ( localItemBackgroundCurrentRow - 1 ) ) ) + ( ( localItemMargin * 3 ) - 1 ), ( inventoryRowWidth * 2 ) - localItemMargin, localItemScale + localItemMargin, tocolor( 0, 0, 0, 0.65 * 255 ), true )
				end
			end
			
			-- Grid bottom fix
			dxDrawRectangle( ( screenWidth - inventoryRowWidth * 2 ) / 2, screenHeight - ( inventoryRowOffset - 1 ), ( inventoryRowWidth * 2 ) - localItemMargin, localItemMargin, tocolor( 0, 0, 0, 0.65 * 255 ), true )
			
			local areWeHovering = false
			
			-- Item Grid
			for localItemIndex, localItem in pairs( items[ categories[ inventoryOpenCategoryID ] ] ) do
				local hovering = false
				
				if ( currentLocalItemIndex == maximumIndex ) then
					currentLocalItemIndex = 0
					currentLocalItemRow = currentLocalItemRow + 1
				end
				
				if ( localItemIndex == #items[ categories[ inventoryOpenCategoryID ] ] ) then
					currentLocalItemIndex = 0
					currentLocalItemRow = 1
				end
				
				currentLocalItemIndex = currentLocalItemIndex + 1
				
				if	( cursorX >= ( ( ( ( screenWidth - inventoryRowWidth - ( localItemScale + localItemMargin ) ) / 2 ) + ( ( localItemScale + localItemMargin ) * ( currentLocalItemIndex - 2 ) ) ) + ( localItemMargin / 2 ) ) ) and
					( cursorX <= ( ( ( ( ( screenWidth - ( inventoryRowWidth ) - ( localItemScale + localItemMargin ) ) / 2 ) + ( ( localItemScale + localItemMargin ) * ( currentLocalItemIndex - 2 ) ) ) + ( localItemMargin / 2 ) ) + localItemScale ) ) and
					( cursorY >= ( ( screenHeight - ( ( localItemScale + ( localItemMargin + ( localItemMargin / 2 ) ) ) * 2 ) ) - ( ( localItemScale + localItemMargin ) * ( currentLocalItemRow - 1 ) ) ) ) and
					( cursorY <= ( ( ( screenHeight - ( ( localItemScale + ( localItemMargin + ( localItemMargin / 2 ) ) ) * 2 ) ) - ( ( localItemScale + localItemMargin ) * ( currentLocalItemRow - 1 ) ) ) + localItemScale ) ) and
					( not draggingItemSlot ) then
					hovering = true
					hoveringItemIndex = localItemIndex
					areWeHovering = true
					
					if ( isDeletingItem ) then
						deletingItemIndex = localItemIndex
					else
						deletingItemIndex = false
					end
				end
				
				local fileName = localItem.item_id
				local item = exports.items:getItem( localItem.item_id )
				
				if ( localItem.item_id == 11 ) then
					local weaponData = split( localItem.value, ";" )
					
					if ( #weaponData > 0 ) then
						fileName = fileName .. "_" .. weaponData[ 1 ]
					end
				end
				
				if ( draggingItemSlot ~= localItemIndex ) and ( not isDraggingWorldItem ) then
					local color = tocolor( 0, 0, 0, ( hovering and 0.6 * 255 or 0.5 * 255 ) )
					
					if ( isDeletingItem ) and ( deletingItemIndex == localItemIndex ) then
						color = tocolor( 105, 20, 20, 0.75 * 255 )
					end
					
					dxDrawRectangle( ( ( ( screenWidth - inventoryRowWidth - ( localItemScale + localItemMargin ) ) / 2 ) + ( ( localItemScale + localItemMargin ) * ( currentLocalItemIndex - 2 ) ) ) + ( localItemMargin / 2 ), ( screenHeight - ( ( localItemScale + ( localItemMargin + ( localItemMargin / 2 ) ) )  *2 ) ) - ( ( localItemScale + localItemMargin ) * ( currentLocalItemRow - 1 ) ), localItemScale, localItemScale, color, true)
					dxDrawImage( ( ( ( screenWidth - inventoryRowWidth - ( localItemScale + localItemMargin ) ) / 2 ) + ( ( localItemScale + localItemMargin ) * ( currentLocalItemIndex - 2 ) ) ), ( ( screenHeight - ( ( localItemScale + ( localItemMargin + ( localItemMargin / 2 ) ) ) * 2 ) ) - ( ( localItemScale + localItemMargin ) * ( currentLocalItemRow - 1 ) ) ), localItemScale, localItemScale, "images/" .. fileName .. ".png", 0, 0, 0, tocolor( 255, 255, 255, ( hovering and 0.95 * 255 or 0.8 * 255 ) ), true )
				else
					local playerX, playerY, playerZ = getElementPosition( localPlayer )
					local cameraX, cameraY, cameraZ = getWorldFromScreenPosition( cursorX, cursorY, 0.1 )
					collision, x, y, z, element = processLineOfSight( cameraX, cameraY, cameraZ, worldX, worldY, worldZ )
					distance = maxDistance
					
					if ( x ) and ( y ) and ( z ) then
						distance = getDistanceBetweenPoints3D( x, y, z, playerX, playerY, playerZ )
					end
					
					local color = tocolor( 0, 0, 0, 0.6 * 255 )
					
					if ( not collision ) or ( distance >= maxDistance ) then
						color = tocolor( 155, 25, 25, 0.7 * 255 )
					elseif ( isElement( element ) ) and ( getElementType( element ) == "player" ) then
						color = tocolor( 25, 155, 25, 0.7 * 255 )
					end
					
					dxDrawRectangle( cursorX, cursorY, localItemScale, localItemScale, color, true )
					dxDrawImage( cursorX + ( localItemScale / 8 ) - 1, cursorY + ( localItemScale / 8 ) - 4, localItemScale - 18, localItemScale - 18, "images/" .. fileName .. ".png", 0, 0, 0, tocolor( 255, 255, 255, 0.95 * 255 ), true )
				end
			end
			
			if ( not areWeHovering ) then
				hoveringItemIndex = false
				deletingItemIndex = false
			end
			
			-- Hovering
			if ( not draggingItemSlot ) then
				for i, localItem in pairs( items[ categories[ inventoryOpenCategoryID ] ] ) do
					if ( currentHoverItemIndex == maximumIndex ) then
						currentHoverItemIndex = 0
						currentHoverItemRow = currentHoverItemRow + 1
					end
					
					if ( i == #items[ categories[ inventoryOpenCategoryID ] ] ) then
						currentHoverItemIndex = 0
						currentHoverItemRow = 1
					end
					
					currentHoverItemIndex = currentHoverItemIndex + 1
					
					if	( cursorX >= ( ( ( ( screenWidth - inventoryRowWidth - ( localItemScale + localItemMargin ) ) / 2 ) + ( ( localItemScale + localItemMargin ) * ( currentHoverItemIndex - 2 ) ) ) + ( localItemMargin / 2 ) ) ) and
						( cursorX <= ( ( ( ( ( screenWidth - inventoryRowWidth - ( localItemScale + localItemMargin ) ) / 2 ) + ( ( localItemScale + localItemMargin ) * ( currentHoverItemIndex - 2 ) ) ) + ( localItemMargin / 2 ) ) + localItemScale ) ) and
						( cursorY >= ( ( screenHeight - ( ( localItemScale + ( localItemMargin + ( localItemMargin / 2 ) ) ) * 2 ) ) - ( ( localItemScale + localItemMargin ) * ( currentHoverItemRow - 1 ) ) ) ) and
						( cursorY <= ( ( ( screenHeight - ( ( localItemScale + ( localItemMargin + ( localItemMargin / 2 ) ) ) * 2 ) ) - ( ( localItemScale + localItemMargin ) * ( currentHoverItemRow - 1 ) ) ) + localItemScale ) ) then
						local item = exports.items:getItem( localItem.item_id )
						local name = item.name
						local value = item.description
						local length = 200
						
						if ( inventoryOpenCategoryID == 2 ) then
							name = item.name .. " (" .. localItem.value .. ")"
							value = item.value
						else
							name = item.name
						end
						
						if ( not value ) or ( value == "" ) then
							value = item.description
						end
						
						if ( localItem.item_id == 10 ) then
							name = item.name .. " (#" .. localItem.value .. ")"
						elseif ( localItem.item_id == 11 ) then
							local parts = split( localItem.value, ";" )
							
							if ( #parts >= 2 ) and ( #parts <= 3 ) then
								name = parts[ 2 ]
								
								if ( #parts == 3 ) then
									value = parts[ 3 ]
								end
							else
								name = item.name
							end
						elseif ( localItem.item_id == 12 ) then
							local parts = split( localItem.value, ";" )
							
							if ( #parts >= 2 ) then
								name = name .. " (@" .. getWeaponNameFromID( parts[ 1 ] ) .. ") (" .. parts[ 2 ] .. " bullets)"
							else
								name = item.name
							end
						end
						
						local nameLength = math.max( 200, dxGetTextWidth( name ) * 1.5 )
						local valueLength = math.max( 200, dxGetTextWidth( value ) * 1.5 )
						
						if ( string.len( name ) > string.len( value ) ) then
							length = nameLength
						else
							length = valueLength
						end
						
						dxDrawRectangle( cursorX, cursorY, length, 57, tocolor( 0, 0, 0, 0.5 * 255 ), true )
						dxDrawText( name .. ( value == "" and "" or "\n" .. value ), cursorX + 17, cursorY + 15, length, 50, tocolor( 245, 245, 245, 255 ), 1.0, "clear", "left", "top", false, false, true, false, true )
					end
				end
			end
		end
	end
)

addEventHandler( "onClientCursorMove", root,
	function( _, _, cursorX, cursorY, worldX, worldY, worldZ )
		if ( not isElement( isDraggingWorldItem ) ) then
			local isHovering = false
			
			for categoryID = 0, #categories - 1 do
				if	( cursorX >= ( screenWidth - inventoryRowWidth + ( localItemScale * 2 * categoryID ) ) / 2 + ( localItemMargin * ( categoryID + 1 ) ) ) and
					( cursorX <= ( ( screenWidth - inventoryRowWidth + ( localItemScale * 2 * categoryID ) ) / 2 + ( localItemMargin * ( categoryID + 1 ) ) ) + localItemScale ) and
					( cursorY >= ( screenHeight - ( inventoryRowOffset - 4 ) ) ) and
					( cursorY <= ( screenHeight - ( inventoryRowOffset - 4 ) ) + localItemScale ) then
					hoveringCategoryID = categoryID + 1
					isHovering = true
				end
			end
			
			if ( not isHovering ) then
				hoveringCategoryID = nil
			end
		--[[else
			local cameraX, cameraY, cameraZ = getWorldFromScreenPosition( cursorX, cursorY, 0.1 )
			local collision, x, y, z, element = processLineOfSight( cameraX, cameraY, cameraZ, worldX, worldY, worldZ, true, true, false, true, true, true, false, true, localPlayer, false, true )
			
			if ( not collision ) then
				return
			end
			
			setElementPosition( isDraggingWorldItem, x, y, getGroundPosition( x, y, z ) )
			setElementRotation( isDraggingWorldItem, 0, 0, getPedRotation( localPlayer ) )]]
		end
	end
)

addEventHandler( "onClientKey", root,
	function( button, pressOrRelease )
		if ( draggingItemSlot ) then
			isDeletingItem = false
			return
		end
		
		if ( button == "delete" ) then
			isDeletingItem = pressOrRelease
		end
	end
)

addEventHandler( "onClientClick", root,
	function( button, state, cursorX, cursorY, worldX, worldY, worldZ, clickedWorld )
		if ( button ~= "left" ) then
			return
		end
		
		if ( draggingItemSlot ) and ( isDeletingItem ) then
			isDeletingItem = false
		end
		
		if ( state == "down" ) then
			if ( isInventoryVisible ) then
				clickCursorX, clickCursorY = cursorX, cursorY
				
				setTimer( function( )
					if ( getKeyState( "mouse1" ) ) then
						if ( items ) then
							if ( not inventoryOpenCategoryID ) then
								return
							end
							
							for localItemIndex, localItem in pairs( items[ categories[ inventoryOpenCategoryID ] ] ) do
								if ( draggingIndex == maximumIndex ) then
									draggingIndex = 0
									draggingRow = draggingRow + 1
								end
								
								if ( localItemIndex == #items[ categories[ inventoryOpenCategoryID ] ] ) then
									draggingIndex = 0
									draggingRow = 1
								end
								
								draggingIndex = draggingIndex + 1
								
								if	( clickCursorX >= ( ( ( ( screenWidth - inventoryRowWidth - ( localItemScale + localItemMargin ) ) / 2 ) + ( ( localItemScale + localItemMargin ) * ( draggingIndex - 2 ) ) ) + ( localItemMargin / 2 ) ) ) and
									( clickCursorX <= ( ( ( ( ( screenWidth - inventoryRowWidth - ( localItemScale + localItemMargin ) ) / 2 ) + ( ( localItemScale + localItemMargin ) * ( draggingIndex - 2 ) ) ) + ( localItemMargin / 2 ) ) + localItemScale ) ) and
									( clickCursorY >= ( ( screenHeight - ( ( localItemScale + ( localItemMargin + ( localItemMargin / 2 ) ) ) * 2 ) ) - ( ( localItemScale + localItemMargin ) * ( draggingRow - 1 ) ) ) ) and
									( clickCursorY <= ( ( ( screenHeight - ( ( localItemScale + ( localItemMargin + ( localItemMargin / 2 ) ) ) * 2 ) ) - ( ( localItemScale + localItemMargin ) * ( draggingRow - 1 ) ) ) + localItemScale ) ) then
									if ( illegalDrop[ localItem.item_id ] ) and ( not exports.common:isPlayerServerTrialAdmin( localPlayer ) ) then
										outputChatBox( "You are not able to drop this item.", 230, 95, 95, false )
									else
										draggingItemSlot = localItemIndex
									end
								end
							end
						end
					end
				end, 200, 1 )
			else
				if ( not isDraggingWorldItem ) then
					local element = isHoveringWorldItem( )
					
					if ( isElement( element ) ) and ( getElementType( element ) == "object" ) then
						if ( not isPedInVehicle( localPlayer ) ) then
							local itemData = exports.items:isWorldItem( element )
							
							if ( itemData ) then
								setTimer( function( )
									if ( not isDraggingWorldItem ) and ( getKeyState( "mouse1" ) ) then
										local element = isHoveringWorldItem( )
										
										if ( element ) then
											local itemData = exports.items:isWorldItem( element )
											
											if ( itemData ) then
												local x, y, z = getElementPosition( element )
												local _, _, rotation = getElementRotation( element )
												
												setElementData( element, "temp:origin_x", x, false )
												setElementData( element, "temp:origin_y", y, false )
												setElementData( element, "temp:origin_z", z, false )
												setElementData( element, "temp:origin_rotation", rotation, false )
												
												isDraggingWorldItem = element
												
												setElementAlpha( isDraggingWorldItem, 200 )
											end
										end
									end
								end, 200, 1 )
							end
						end
					end
				end
			end
		end
		
		if ( state == "up" ) then
			if ( isDraggingWorldItem ) then
				worldZ = getGroundPosition( worldX, worldY, worldZ )
				
				if ( getDistanceBetweenPoints3D( worldX, worldY, worldZ, getElementPosition( localPlayer ) ) < 14 ) then
					local itemData = exports.items:isWorldItem( isDraggingWorldItem )
					triggerServerEvent( "items:updateposition", localPlayer, itemData.id, isDraggingWorldItem, worldX, worldY, worldZ )
				else
					outputChatBox( "Sorry, but that's too far.", 245, 20, 20, false )
					setElementPosition( isDraggingWorldItem, tonumber( getElementData( isDraggingWorldItem, "temp:origin_x" ) ), tonumber( getElementData( isDraggingWorldItem, "temp:origin_y" ) ), tonumber( getElementData( isDraggingWorldItem, "temp:origin_z" ) ) )
					setElementRotation( isDraggingWorldItem, 0, 0, tonumber( getElementData( isDraggingWorldItem, "temp:origin_rotation" ) ) )
				end
				
				setElementAlpha( isDraggingWorldItem, 255 )
				isDraggingWorldItem = false
			else
				local element = isHoveringWorldItem( )
				
				if ( isElement( element ) ) and ( getElementType( element ) == "object" ) then
					local itemData = exports.items:isWorldItem( element )
					
					if ( itemData ) then
						if ( not isPedInVehicle( localPlayer ) ) then
							if ( tonumber( getElementData( localPlayer, "character:weight" ) ) + exports.items:getItemWeight( itemData.item_id ) <= tonumber( getElementData( localPlayer, "character:max_weight" ) ) ) then
								local item = exports.items:getItem( itemData.item_id )
								local name = item.name
								local value = item.value
								
								triggerServerEvent( "items:pickup", localPlayer, itemData.id, element )
								
								return
							else
								outputChatBox( "You don't have enough space for that item in your inventory.", 230, 95, 95, false )
							end
						else
							outputChatBox( "You have to get out of the vehicle in order to pick up the item.", 230, 95, 95, false )
						end
					end
				end
				
				if ( draggingItemSlot ) then
					local localItem = items[ categories[ inventoryOpenCategoryID ] ][ draggingItemSlot ]
					
					if ( localItem ) then
						if ( not collision ) or ( distance >= maxDistance ) then
							outputChatBox( "That's outer space, monkey." )
						elseif ( element ) and ( element ~= localPlayer ) then
							triggerServerEvent( "items:drop", localPlayer, element, localItem.db_id, localItem.item_id, localItem.value, localItem.ringtone_id, localItem.messagetone_id, worldX, worldY, worldZ )
						elseif ( element ) and ( element == localPlayer ) then
							outputChatBox( "Giving yourself a present? Aw, how cute!" )
						else
							triggerServerEvent( "items:drop", localPlayer, false, localItem.db_id, localItem.item_id, localItem.value, localItem.ringtone_id, localItem.messagetone_id, worldX, worldY, worldZ )
						end
					end
					
					draggingItemSlot = nil
				else
					for categoryID = 0, #categories - 1 do
						if	( cursorX >= ( screenWidth - inventoryRowWidth + 7 + ( localItemScale * 2 * categoryID ) ) / 2 ) and
							( cursorX <= ( ( screenWidth - inventoryRowWidth + 7 + ( localItemScale * 2 * categoryID ) ) / 2 ) + localItemScale ) and
							( cursorY >= ( screenHeight - ( inventoryRowOffset - 4 ) ) ) and
							( cursorY <= ( screenHeight - ( inventoryRowOffset - 4 ) ) + localItemScale ) then
							if ( not doesContainData( categoryID + 1 ) ) then
								return
							end
							
							if ( inventoryOpenCategoryID == categoryID + 1 ) then
								inventoryOpenCategoryID = nil
								return
							end
							
							inventoryOpenCategoryID = categoryID + 1
						end
					end
					
					if ( items ) then
						if ( not inventoryOpenCategoryID ) then
							return
						end
						
						for i, v in pairs( items[ categories[ inventoryOpenCategoryID ] ] ) do
							if ( currentClickItemIndex == maximumIndex ) then
								currentClickItemIndex = 0
								currentClickItemRow = currentClickItemRow + 1
							end
							
							if ( i == #items[ categories[ inventoryOpenCategoryID ] ] ) then
								currentClickItemIndex = 0
								currentClickItemRow = 1
							end
							
							currentClickItemIndex = currentClickItemIndex + 1
							
							if  ( cursorX >= ( ( ( ( screenWidth - inventoryRowWidth - ( localItemScale + localItemMargin ) ) / 2 ) + ( ( localItemScale + localItemMargin ) * ( currentClickItemIndex - 2 ) ) ) + ( localItemMargin / 2 ) ) ) and
								( cursorX <= ( ( ( ( ( screenWidth - inventoryRowWidth - ( localItemScale + localItemMargin ) ) / 2 ) + ( ( localItemScale + localItemMargin ) * ( currentClickItemIndex - 2 ) ) ) + ( localItemMargin / 2 ) ) + localItemScale ) ) and
								( cursorY >= ( ( screenHeight - ( ( localItemScale + ( localItemMargin + ( localItemMargin / 2 ) ) ) * 2 ) ) - ( ( localItemScale + localItemMargin ) * ( currentClickItemRow - 1 ) ) ) ) and
								( cursorY <= ( ( ( screenHeight - ( ( localItemScale + ( localItemMargin + ( localItemMargin / 2 ) ) ) * 2 ) ) - ( ( localItemScale + localItemMargin ) * ( currentClickItemRow - 1 ) ) ) + localItemScale ) ) then
								local localItem = items[ categories[ inventoryOpenCategoryID ] ][ i ]
								
								if ( isDeletingItem ) and ( deletingItemIndex == i ) then
									deletingItemIndex = false
									
									triggerServerEvent( "items:delete", localPlayer, localItem.db_id, localItem.item_id, localItem.value )
								else
									triggerServerEvent( "items:act", localPlayer, localItem.db_id, localItem.item_id, localItem.value )
									
									if ( localItem.item_id == 10 ) then
										isInventoryLocked = true
									end
								end
							end
						end
					end
				end
			end
		end
	end
)

addEvent( "inventory:synchronize", true )
addEventHandler( "inventory:synchronize", root,
	function( serverItems )
		for index, _ in pairs( items ) do
			items[ index ] = { }
		end
		
		for i, v in pairs( serverItems ) do
			if ( v.item_id ) then
				local type = categories[ exports.items:getItemType( v.item_id ) ]
				
				if ( type ) then
					table.insert( items[ type ], { name = v.name, item_id = v.item_id, value = v.value, ringtone_id = v.ringtone_id, messagetone_id = v.messagetone_id } )
				end
			end
		end
		
		if ( inventoryOpenCategoryID ) then
			if ( not doesContainData( inventoryOpenCategoryID ) ) then
				inventoryOpenCategoryID = nil
			end
		end
	end
)

addCommandHandler( "fixinventory",
	function( )
		if ( not inventoryCooldownTimer ) then
			inventoryCooldownTimer = setTimer( function( )
				inventoryCooldownTimer = nil
			end, 5000, 1 )
			
			outputChatBox( "Attempting to fix your inventory now...", 95, 230, 95, false )
			triggerServerEvent( "items:get", localPlayer )
		else
			outputChatBox( "Please wait a moment before fixing the inventory again!", 230, 95, 95, false )
		end
	end
)

local function toggleInventory( )
	if ( exports.common:isPlayerPlaying( localPlayer ) ) and ( not isPedDead( localPlayer ) ) then
		if ( isInventoryLocked ) then
			outputChatBox( "Inventory cannot be accessed at this time.", 230, 95, 95, false )
		else
			if ( not isInventoryVisible ) then
				if ( getElementData( localPlayer, "temp:need_synchronization" ) ) then
					triggerServerEvent( "items:synchronize", localPlayer )
					setElementData( localPlayer, "temp:need_synchronization", false, false )
				end
			end
			
			isInventoryVisible = not isInventoryVisible
			
			toggleAllControls( not isInventoryVisible, true, false )
			showCursor( isInventoryVisible, isInventoryVisible )
			
			hoveringCategoryID = nil
			inventoryOpenCategoryID = nil
			isDeletingItem = nil
			isDraggingWorldItem = false
		end
	end
end
addCommandHandler( { "inventory", "inv", "toggleinventory", "toginventory" }, toggleInventory )

addEvent( "inventory:unlock", true )
addEventHandler( "inventory:unlock", root,
	function( )
		isInventoryLocked = false
	end
)

addEvent( "inventory:close", true )
addEventHandler( "inventory:close", root,
	function( )
		isInventoryVisible = false
		
		toggleAllControls( true, true, false )
		showCursor( false, false )
		
		hoveringCategoryID = nil
		inventoryOpenCategoryID = nil
		isDeletingItem = nil
		isDraggingWorldItem = false
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		bindKey( "i", "down", toggleInventory )
		
		if ( exports.common:isPlayerPlaying( localPlayer ) ) then
			triggerServerEvent( "items:get", localPlayer )
		end
	end
)

addEventHandler( "onClientResourceStop", resourceRoot,
	function( )
		toggleAllControls( true, true, false )
	end
)