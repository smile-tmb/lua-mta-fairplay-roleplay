-- General Stuff
local screenWidth, screenHeight = guiGetScreenSize( )
local isVisible = false
local postGUI = true
local illegalDrop = { [ 9 ] = true }
local cases = { "backpack", "keys", "weapons" }
local items = {
	backpack = { },
	keys = { },
	weapons = { }
}

-- Inventory Settings
local GLOBAL_max = 6
local GLOBAL_cooldown = false
local GLOBAL_debug = false

local CATEGORY_hovering
local CATEGORY_open

local BG_currentIndex = 0
local BG_currentRow = 1

local ROW_width = 282.0
local ROW_offset = 100.0

local ITEM_scale = 90
local ITEM_margin = 3
local ITEM_currentIndex = 0
local ITEM_currentRow = 1

local HOVER_currentIndex = 0
local HOVER_currentRow = 1

local CLICK_currentIndex = 0
local CLICK_currentRow = 1

local dist
local col, x, y, z, element
local _cursorX, _cursorY = 0, 0
local maxDistance = 6
local DRAG_item
local DRAG_currentIndex = 0
local DRAG_currentRow = 1
local DELETING = false
local draggingWorldItem = false

local DRAGEND_currentIndex = 0
local DRAGEND_currentRow = 1
local LOCKINVENTORY = false

-- Script
local function doesContainData( case )
	if ( not items[ cases[ case ] ] ) or ( #items[ cases[ case ] ] == 0 ) then
		return false
	else
		return true
	end
end

local function isHoveringWorldItem( )
	local cursorX, cursorY, worldX, worldY, worldZ = getCursorPosition( )
	local cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
	local cameraX, cameraY, cameraZ = getWorldFromScreenPosition( cursorX, cursorY, 0.1 )
	local _, x, y, z, element = processLineOfSight( cameraX, cameraY, cameraZ, worldX, worldY, worldZ )
	
	if ( element ) and ( exports.items:isWorldItem( element ) ) then
		return element
	elseif ( _x ) and ( _y ) and ( _z ) then
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
			local element = isHoveringWorldItem( )
			
			if ( element ) and ( getElementType( element ) == "object" ) then
				local cursorX, cursorY, worldX, worldY, worldZ = getCursorPosition( )
				local cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
				local itemData = exports.items:isWorldItem( element )
				
				if ( itemData ) then
					local item = exports.items:getItems( )[ itemData.item_id ]
					local name = item.name
					local value = item.value
					local length = 200
					
					if ( item.type == 2 ) or ( item.type == 3 ) then
						name = name .. " (" .. itemData.value .. ")"
					elseif ( itemData.item_id == 10 ) then
						name = name .. " (#" .. itemData.value .. ")"
					else
						if ( itemData.value ) and ( itemData.value ~= "" ) then
							value = item.description
						end
					end
					
					local nameLength = math.max( 200, dxGetTextWidth( name ) * 1.5 )
					local valueLength = math.max( 200, dxGetTextWidth( value ) * 1.5 )
					
					if ( string.len( name ) > string.len( value ) ) then
						length = nameLength
					else
						length = valueLength
					end
					
					dxDrawRectangle( cursorX, cursorY, length, 57, tocolor( 0, 0, 0, 0.5 * 255 ), postGUI )
					dxDrawText( name .. "\n" .. value, cursorX + 17, cursorY + 15, length, 50, tocolor( 245, 245, 245, 255 ), 1.0, "clear", "left", "top", false, false, postGUI, false, true )
				end
			end
		end
		
		if ( not isVisible ) then
			return
		end
		
		-- Background
		dxDrawRectangle((screenWidth-ROW_width)/2, (CATEGORY_open ~= nil and screenHeight-ROW_offset+4 or screenHeight-ROW_offset), ROW_width, screenHeight, tocolor(0, 0, 0, 0.65*255), postGUI)
		dxDrawRectangle((screenWidth-ROW_width)/2, screenHeight-2, ROW_width, screenHeight, tocolor(245, 245, 245, 0.9*255), postGUI)
		
		-- Backpack
		dxDrawRectangle((screenWidth-ROW_width+7)/2, screenHeight-(ROW_offset-4), ITEM_scale, ITEM_scale, tocolor(0, 0, 0, (CATEGORY_hovering == 1 and 0.6*255 or 0.5*255)), postGUI)
		dxDrawImage((screenWidth-ROW_width+9)/2+8, screenHeight-(ROW_offset-9)-2, ITEM_scale-20, ITEM_scale-10, "images/backpack.png", 0, 0, 0, tocolor(255, 255, 255, (CATEGORY_hovering == 1 and 0.95*255 or 0.8*255)), postGUI)
		
		-- Keys
		dxDrawRectangle((screenWidth-ROW_width+ITEM_scale*2+12)/2, screenHeight-(ROW_offset-4), ITEM_scale, ITEM_scale, tocolor(0, 0, 0, (CATEGORY_hovering == 2 and 0.6*255 or 0.5*255)), postGUI)
		dxDrawImage((screenWidth-ROW_width+ITEM_scale*2+26)/2+2, screenHeight-(ROW_offset-12), ITEM_scale-20, ITEM_scale-15, "images/keys.png", 0, 0, 0, tocolor(255, 255, 255, (CATEGORY_hovering == 2 and 0.95*255 or 0.8*255)), postGUI)
		
		-- Weapons
		dxDrawRectangle((screenWidth-ROW_width+ITEM_scale*4+17)/2, screenHeight-(ROW_offset-4), ITEM_scale, ITEM_scale, tocolor(0, 0, 0, (CATEGORY_hovering == 3 and 0.6*255 or 0.5*255)), postGUI)
		dxDrawImage((screenWidth-ROW_width+ITEM_scale*4+25)/2+2, screenHeight-(ROW_offset-14)+5, ITEM_scale-13, ITEM_scale-35, "images/weapons.png", 0, 0, 0, tocolor(255, 255, 255, (CATEGORY_hovering == 3 and 0.95*255 or 0.8*255)), postGUI)
		
		local cursorX, cursorY, worldX, worldY, worldZ = getCursorPosition( )
		local cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
		
		if ( CATEGORY_open ) then
			-- Background
			for i,v in pairs(items[cases[CATEGORY_open]]) do
				if (BG_currentIndex == GLOBAL_max) then
					BG_currentIndex = 0
					BG_currentRow = BG_currentRow+1
				end
				
				if (i == #items[cases[CATEGORY_open]]) then
					BG_currentIndex = 0
					BG_currentRow = 1
				end
				
				BG_currentIndex = BG_currentIndex+1
				
				if (BG_currentIndex == 1) then
					dxDrawRectangle((screenWidth-ROW_width*2)/2, ((screenHeight-(ROW_offset*2))-((ITEM_scale+ITEM_margin)*(BG_currentRow-1)))+((ITEM_margin*3)-1), (ROW_width*2)-ITEM_margin, ITEM_scale+(ITEM_margin), tocolor(0, 0, 0, 0.65*255), postGUI)
				end
			end
			
			-- Grid bottom fix
			dxDrawRectangle((screenWidth-ROW_width*2)/2, screenHeight-(ROW_offset-1), (ROW_width*2)-ITEM_margin, ITEM_margin, tocolor(0, 0, 0, 0.65*255), postGUI)
			
			-- Item Grid
			for i,v in pairs(items[cases[CATEGORY_open]]) do
				local hovering = false
				
				if (ITEM_currentIndex == GLOBAL_max) then
					ITEM_currentIndex = 0
					ITEM_currentRow = ITEM_currentRow+1
				end
				
				if (i == #items[cases[CATEGORY_open]]) then
					ITEM_currentIndex = 0
					ITEM_currentRow = 1
				end
				
				ITEM_currentIndex = ITEM_currentIndex+1
				
				if (cursorX >= ((((screenWidth-(ROW_width)-(ITEM_scale+ITEM_margin))/2)+((ITEM_scale+ITEM_margin)*(ITEM_currentIndex-2)))+(ITEM_margin/2))) and (cursorX <= (((((screenWidth-(ROW_width)-(ITEM_scale+ITEM_margin))/2)+((ITEM_scale+ITEM_margin)*(ITEM_currentIndex-2)))+(ITEM_margin/2))+ITEM_scale)) and (cursorY >= ((screenHeight-((ITEM_scale+(ITEM_margin+(ITEM_margin/2)))*2))-((ITEM_scale+ITEM_margin)*(ITEM_currentRow-1)))) and (cursorY <= (((screenHeight-((ITEM_scale+(ITEM_margin+(ITEM_margin/2)))*2))-((ITEM_scale+ITEM_margin)*(ITEM_currentRow-1)))+ITEM_scale)) and (not DRAG_item) then
					hovering = true
				end
				
				if (DRAG_item ~= i) then
					dxDrawRectangle((((screenWidth-(ROW_width)-(ITEM_scale+ITEM_margin))/2)+((ITEM_scale+ITEM_margin)*(ITEM_currentIndex-2)))+(ITEM_margin/2), (screenHeight-((ITEM_scale+(ITEM_margin+(ITEM_margin/2)))*2))-((ITEM_scale+ITEM_margin)*(ITEM_currentRow-1)), ITEM_scale, ITEM_scale, tocolor(0, 0, 0, (hovering and 0.6*255 or 0.5*255)), postGUI)
					dxDrawImage((((screenWidth-(ROW_width)-(ITEM_scale+ITEM_margin))/2)+((ITEM_scale+ITEM_margin)*(ITEM_currentIndex-2)))+(ITEM_scale/8), ((screenHeight-((ITEM_scale+(ITEM_margin+(ITEM_margin/2)))*2))-((ITEM_scale+ITEM_margin)*(ITEM_currentRow-1)))+(((ITEM_scale/8)/2)+3), ITEM_scale-18, ITEM_scale-18, "images/" .. items[cases[CATEGORY_open]][i].item_id .. ".png", 0, 0, 0, tocolor(255, 255, 255, (hovering and 0.95*255 or 0.8*255)), postGUI)
				else
					local px, py, pz = getElementPosition(localPlayer)
					local camX, camY, camZ = getWorldFromScreenPosition(cursorX, cursorY, 0.1)
					col, x, y, z, element = processLineOfSight(camX, camY, camZ, worldX, worldY, worldZ)
					dist = maxDistance
					
					if (x) and (y) and (z) then
						dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
					end
					
					local color = tocolor(0, 0, 0, 0.6*255)
					
					if (not col) or (dist >= maxDistance) then
						color = tocolor(155, 25, 25, 0.7*255)
					elseif (element) and (getElementType(element) == "player") then
						color = tocolor(25, 155, 25, 0.7*255)
					elseif (DELETING) then
						color = tocolor(105, 20, 20, 0.75*255)
					end
					
					dxDrawRectangle(cursorX, cursorY, ITEM_scale, ITEM_scale, color, postGUI)
					dxDrawImage(cursorX+(ITEM_scale/8)-1, cursorY+(ITEM_scale/8)-4, ITEM_scale-18, ITEM_scale-18, "images/" .. items[cases[CATEGORY_open]][i].item_id .. ".png", 0, 0, 0, tocolor(255, 255, 255, 0.95*255), postGUI)
				end
			end
			
			-- Hovering
			if (not DRAG_item) then
				for i,v in pairs(items[cases[CATEGORY_open]]) do
					if (HOVER_currentIndex == GLOBAL_max) then
						HOVER_currentIndex = 0
						HOVER_currentRow = HOVER_currentRow+1
					end
					
					if (i == #items[cases[CATEGORY_open]]) then
						HOVER_currentIndex = 0
						HOVER_currentRow = 1
					end
					
					HOVER_currentIndex = HOVER_currentIndex+1
					
					if (cursorX >= ((((screenWidth-(ROW_width)-(ITEM_scale+ITEM_margin))/2)+((ITEM_scale+ITEM_margin)*(HOVER_currentIndex-2)))+(ITEM_margin/2))) and (cursorX <= (((((screenWidth-(ROW_width)-(ITEM_scale+ITEM_margin))/2)+((ITEM_scale+ITEM_margin)*(HOVER_currentIndex-2)))+(ITEM_margin/2))+ITEM_scale)) and (cursorY >= ((screenHeight-((ITEM_scale+(ITEM_margin+(ITEM_margin/2)))*2))-((ITEM_scale+ITEM_margin)*(HOVER_currentRow-1)))) and (cursorY <= (((screenHeight-((ITEM_scale+(ITEM_margin+(ITEM_margin/2)))*2))-((ITEM_scale+ITEM_margin)*(HOVER_currentRow-1)))+ITEM_scale)) then
						local name
						local item = exports.items:getItems()[v.item_id]
						local value = ""
						local length = 200
						
						if (CATEGORY_open == 2) then
							name = item.name .. " (" .. v.value .. ")"
							value = item.value
						else
							name = item.name
						end
						
						if (not value or value == "") then
							value = item.description
						end
						
						if (v.item_id == 10) then
							name = item.name .. " (#" .. v.value .. ")"
						end
						
						local nameLength = math.max(200, dxGetTextWidth(name)*1.5)
						local valueLength = math.max(200, dxGetTextWidth(value)*1.5)
						
						if (string.len(name) > string.len(value)) then
							length = nameLength
						else
							length = valueLength
						end
						
						dxDrawRectangle(cursorX, cursorY, length, 57, tocolor(0, 0, 0, 0.5*255), postGUI)
						dxDrawText(name .. "\n" .. value, cursorX+17, cursorY+15, length, 50, tocolor(245, 245, 245, 255), 1.0, "clear", "left", "top", false, false, postGUI, false, true)
					end
				end
			end
		end
	end
)

addEventHandler( "onClientCursorMove", root,
	function( cursorX, cursorY, cursorX, cursorY, worldX, worldY, worldZ )
		if ( not draggingWorldItem ) or ( not isElement( draggingWorldItem ) ) then
			-- Inventory
			if (cursorX >= (screenWidth-ROW_width+7)/2) and (cursorX <= ((screenWidth-ROW_width+7)/2)+ITEM_scale) and (cursorY >= (screenHeight-(ROW_offset-4))) and (cursorY <= (screenHeight-(ROW_offset-4))+ITEM_scale) then
				-- Backpack
				if ( CATEGORY_hovering == 1 ) then
					return
				end
				CATEGORY_hovering = 1
			elseif (cursorX >= (screenWidth-ROW_width+ITEM_scale*2+12)/2) and (cursorX <= ((screenWidth-ROW_width+ITEM_scale*2+12)/2)+ITEM_scale) and (cursorY >= (screenHeight-(ROW_offset-4))) and (cursorY <= (screenHeight-(ROW_offset-4))+ITEM_scale) then
				-- Keys
				if ( CATEGORY_hovering == 2 ) then
					return
					end
				CATEGORY_hovering = 2
			elseif (cursorX >= (screenWidth-ROW_width+ITEM_scale*4+17)/2) and (cursorX <= ((screenWidth-ROW_width+ITEM_scale*4+16)/2)+ITEM_scale) and (cursorY >= (screenHeight-(ROW_offset-4))) and (cursorY <= (screenHeight-(ROW_offset-4))+ITEM_scale) then
				-- Weapons
				if ( CATEGORY_hovering == 3 ) then
					return
				end
				CATEGORY_hovering = 3
			else
				if ( CATEGORY_hovering == nil ) then
					return
				end
				CATEGORY_hovering = nil
			end
		else
			if ( not draggingWorldItem ) or ( not isElement( draggingWorldItem ) ) then
				return
			end
			
			local px, py, pz = getElementPosition( localPlayer )
			local camX, camY, camZ = getWorldFromScreenPosition( cursorX, cursorY, 0.1 )
			local col, x, y, z, element = processLineOfSight( camX, camY, camZ, worldX, worldY, worldZ )
			
			if ( not col ) then
				return
			end
			
			local dist2 = maxDistance
			setElementPosition( draggingWorldItem, x, y, z )
		end
	end
)

addEventHandler( "onClientKey", root,
	function( button, pressOrRelease )
		if ( not DRAG_item ) and ( DELETING ) then
			DELETING = false
		end
		
		if ( button == "delete" ) then
			if ( DRAG_item ) then
				if ( pressOrRelease == true ) and ( not DELETING ) then
					DELETING = true
				else
					if ( not DELETING ) then
						return
					end
					
					DELETING = false
					triggerServerEvent( "items:delete", localPlayer, items[ cases[ CATEGORY_open ] ][ DRAG_item ].db_id, items[ cases[ CATEGORY_open ] ][ DRAG_item ].item_id, items[ cases[ CATEGORY_open ] ][ DRAG_item ].value )
					DRAG_item = false
				end
			end
		elseif ( ( button == "backspace" ) or ( button == "escape" ) ) and ( DELETING ) then
			DELETING = false
		end
	end
)

addEventHandler( "onClientClick", root,
	function( button, state, cursorX, cursorY, worldX, worldY, worldZ, clickedWorld )
		if ( button ~= "left" ) then
			return
		end
		
		if ( not DRAG_item ) and ( DELETING ) then
			DELETING = false
		end
		
		if ( state == "down" ) then
			if ( isVisible ) then
				_cursorX, _cursorY = cursorX, cursorY
				
				setTimer( function( )
					if ( getKeyState( "mouse1" ) == true ) then
						if ( items ) then
							if ( not CATEGORY_open ) then
								return
							end
							
							for i, v in pairs( items[ cases[ CATEGORY_open ] ] ) do
								if ( DRAG_currentIndex == GLOBAL_max ) then
									DRAG_currentIndex = 0
									DRAG_currentRow = DRAG_currentRow + 1
								end
								
								if ( i == #items[ cases[ CATEGORY_open ] ] ) then
									DRAG_currentIndex = 0
									DRAG_currentRow = 1
								end
								
								DRAG_currentIndex = DRAG_currentIndex + 1
								
								if	( _cursorX >= ( ( ( ( screenWidth - ROW_width - ( ITEM_scale + ITEM_margin ) ) / 2 ) + ( ( ITEM_scale + ITEM_margin ) * ( DRAG_currentIndex - 2 ) ) ) + ( ITEM_margin / 2 ) ) ) and
									( _cursorX <= ( ( ( ( ( screenWidth - ROW_width - ( ITEM_scale + ITEM_margin ) ) / 2 ) + ( ( ITEM_scale + ITEM_margin ) * ( DRAG_currentIndex - 2 ) ) ) + ( ITEM_margin / 2 ) ) + ITEM_scale ) ) and
									( _cursorY >= ( ( screenHeight - ( ( ITEM_scale + ( ITEM_margin + ( ITEM_margin / 2 ) ) ) * 2 ) ) - ( ( ITEM_scale + ITEM_margin ) * ( DRAG_currentRow - 1 ) ) ) ) and
									( _cursorY <= ( ( ( screenHeight - ( ( ITEM_scale + ( ITEM_margin + ( ITEM_margin / 2 ) ) ) * 2 ) ) - ( ( ITEM_scale + ITEM_margin ) * ( DRAG_currentRow - 1 ) ) ) + ITEM_scale ) ) then
									if ( illegalDrop[ items[ cases[ CATEGORY_open ] ][ i ].item_id ] ) and ( not exports.common:isPlayerServerTrialAdmin( localPlayer ) ) then
										outputChatBox( "You are unable to drop this item.", 245, 20, 20, false )
									else
										DRAG_item = i
									end
								end
							end
						end
					end
				end, 200, 1)
			else
				if ( not draggingWorldItem ) then
					local element = isHoveringWorldItem( )
					if ( element ) and ( getElementType( element ) == "object" ) then
						if ( not isPedInVehicle( localPlayer ) ) then
							local itemData = exports.items:isWorldItem( element )
							if ( itemData ) then
								setTimer( function( )
									if ( not draggingWorldItem ) and ( getKeyState( "mouse1" ) == true ) then
										local element = isHoveringWorldItem( )
										if ( element ) then
											local itemData = exports.items:isWorldItem( element )
											if ( itemData ) then
												local x, y, z = getElementPosition( element )
												local _, _, rot = getElementRotation( element )
												setElementData( element, "temp:origin_x", x, false )
												setElementData( element, "temp:origin_y", y, false )
												setElementData( element, "temp:origin_z", z, false )
												setElementData( element, "temp:origin_rotation", rot, false )
												draggingWorldItem = element
												setElementAlpha( draggingWorldItem, 200 )
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
			if ( draggingWorldItem ) then
				local x, y, z = getElementPosition( draggingWorldItem )
				
				if ( getDistanceBetweenPoints3D( x, y, z, getElementPosition( localPlayer ) ) < 14 ) then
					local itemData = exports.items:isWorldItem( draggingWorldItem )
					triggerServerEvent( "items:updateposition", localPlayer, itemData[ 1 ], draggingWorldItem, x, y, z )
				else
					outputChatBox( "Sorry, but that's too far.", 245, 20, 20, false )
					setElementPosition( draggingWorldItem, tonumber( getElementData( draggingWorldItem, "temp:origin_x" ) ), tonumber( getElementData( draggingWorldItem, "temp:origin_y" ) ), tonumber( getElementData( draggingWorldItem, "temp:origin_z" ) ) )
					setElementRotation( draggingWorldItem, 0, 0, tonumber( getElementData( draggingWorldItem, "temp:origin_rotation" ) ) )
				end
				
				setElementAlpha( draggingWorldItem, 255 )
				draggingWorldItem = false
			else
				local element = isHoveringWorldItem( )
				
				if ( element ) and ( getElementType( element ) == "object" ) then
					local itemData = exports.items:isWorldItem( element )
					
					if ( itemData ) then
						if ( not isPedInVehicle( localPlayer ) ) then
							if ( tonumber( getElementData( localPlayer, "character:weight" ) ) + exports.items:getItemWeight( itemData.item_id ) <= tonumber( getElementData( localPlayer, "character:max_weight" ) ) ) then
								local item = exports.items:getItems( )[ itemData.item_id ]
								local name = item.name
								local value = item.value
								
								triggerServerEvent( "items:pickup", localPlayer, itemData.id, element )
								
								return
							else
								outputChatBox( "You don't have enough space for that item in your inventory.", 245, 20, 20, false )
							end
						else
							outputChatBox( "You have to get out of the vehicle in order to pick up the item.", 245, 20, 20, false )
						end
					end
				end
				
				if ( DRAG_item ) then
					local item = items[ cases[ CATEGORY_open ] ][ DRAG_item ]
					
					if ( not col ) or ( dist >= maxDistance ) then
						outputChatBox( "That's outer space, monkey." )
					elseif ( element ) and ( element ~= localPlayer ) then
						triggerServerEvent( "items:drop", localPlayer, element, item.db_id, item.item_id, item.value, item.ringtone_id, item.messagetone_id, worldX, worldY, worldZ )
					elseif ( element ) and ( element == localPlayer ) then
						outputChatBox( "Giving yourself a present? Aw, how cute!" )
					else
						triggerServerEvent( "items:drop", localPlayer, false, item.db_id, item.item_id, item.value, item.ringtone_id, item.messagetone_id, worldX, worldY, worldZ )
					end
					
					DRAG_item = nil
				else
					if	( cursorX >= ( screenWidth - ROW_width + 7 ) / 2 ) and
						( cursorX <= ( ( screenWidth - ROW_width + 7 ) / 2 ) + ITEM_scale ) and
						( cursorY >= ( screenHeight - ( ROW_offset - 4 ) ) ) and
						( cursorY <= ( screenHeight - ( ROW_offset - 4 ) ) + ITEM_scale ) then
						if ( not doesContainData( 1 ) ) then
							return
						end
						
						if ( CATEGORY_open == 1 ) then
							CATEGORY_open = nil
							return
						end
						
						CATEGORY_open = 1
					elseif	( cursorX >= ( screenWidth - ROW_width + ITEM_scale * 2 + 12 ) / 2 ) and
							( cursorX <= ( ( screenWidth - ROW_width + ITEM_scale * 2 + 12 ) / 2 ) + ITEM_scale ) and
							( cursorY >= ( screenHeight - ( ROW_offset - 4 ) ) ) and
							( cursorY <= ( screenHeight - ( ROW_offset - 4 ) ) + ITEM_scale ) then
						if ( not doesContainData( 2 ) ) then
							return
						end
						
						if ( CATEGORY_open == 2 ) then
							CATEGORY_open = nil
							return
						end
						
						CATEGORY_open = 2
					elseif	( cursorX >= ( screenWidth - ROW_width + ITEM_scale * 4 + 17 ) / 2 ) and
							( cursorX <= ( ( screenWidth - ROW_width + ITEM_scale * 4 + 17 ) / 2 ) + ITEM_scale ) and
							( cursorY >= ( screenHeight - ( ROW_offset - 4 ) ) ) and
							( cursorY <= ( screenHeight - ( ROW_offset - 4 ) ) + ITEM_scale ) then
						if ( not doesContainData( 3 ) ) then
							return
						end
						
						if ( CATEGORY_open == 3 ) then
							CATEGORY_open = nil
							return
						end
						
						CATEGORY_open = 3
					end
					
					if ( items ) then
						if ( not CATEGORY_open ) then
							return
						end
						
						for i, v in pairs( items[ cases[ CATEGORY_open ] ] ) do
							if ( CLICK_currentIndex == GLOBAL_max ) then
								CLICK_currentIndex = 0
								CLICK_currentRow = CLICK_currentRow + 1
							end
							
							if ( i == #items[ cases[ CATEGORY_open ] ] ) then
								CLICK_currentIndex = 0
								CLICK_currentRow = 1
							end
							
							CLICK_currentIndex = CLICK_currentIndex + 1
							
							if  ( cursorX >= ( ( ( ( screenWidth - ROW_width - ( ITEM_scale + ITEM_margin ) ) / 2 ) + ( ( ITEM_scale + ITEM_margin ) * ( CLICK_currentIndex - 2 ) ) ) + ( ITEM_margin / 2 ) ) ) and
								( cursorX <= ( ( ( ( ( screenWidth - ROW_width- ( ITEM_scale + ITEM_margin ) ) / 2 ) + ( ( ITEM_scale + ITEM_margin ) * ( CLICK_currentIndex - 2 ) ) ) + ( ITEM_margin / 2 ) ) + ITEM_scale ) ) and
								( cursorY >= ( ( screenHeight - ( ( ITEM_scale + ( ITEM_margin + ( ITEM_margin / 2 ) ) ) * 2 ) ) - ( ( ITEM_scale + ITEM_margin ) * ( CLICK_currentRow - 1 ) ) ) ) and
								( cursorY <= ( ( ( screenHeight - ( ( ITEM_scale + ( ITEM_margin + ( ITEM_margin / 2 ) ) ) * 2 ) ) - ( ( ITEM_scale + ITEM_margin ) * ( CLICK_currentRow - 1 ) ) ) + ITEM_scale ) ) then
								local item = items[ cases[ CATEGORY_open ] ][ i ]
								
								triggerServerEvent( "items:act", localPlayer, item.db_id, item.item_id, item.value )
								
								if ( items[ cases[ CATEGORY_open ] ][ i ][ 2 ] == 10 ) then
									LOCKINVENTORY = true
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
	function( items_ )
		items = {
			backpack = { },
			keys = { },
			weapons = { }
		}
		
		for i, v in pairs( items_ ) do
			if ( items_[ i ].item_id ) then
				local type = cases[ exports.items:getItemType( items_[ i ].item_id ) ]
				
				if ( type ) then
					table.insert( items[ type ], { name = items_[ i ].name, item_id = items_[ i ].item_id, value = items_[ i ].value, ringtone_id = items_[ i ].ringtone_id, messagetone_id = items_[ i ].messagetone_id } )
				end
			end
		end
		
		if ( CATEGORY_open ) then
			if ( not doesContainData( CATEGORY_open ) ) then
				CATEGORY_open = nil
			end
		end
	end
)

addCommandHandler( "fixinventory",
	function( )
		if ( not GLOBAL_cooldown ) then
			GLOBAL_cooldown = true
			
			setTimer( function( )
				if ( isElement( localPlayer ) ) then
					GLOBAL_cooldown = not GLOBAL_cooldown
				end
			end, 5000, 1 )
			
			outputChatBox( "Fix deployed!", 20, 245, 20, false )
			triggerServerEvent( "items:get", localPlayer )
		else
			outputChatBox("Please wait a moment before fixing the inventory again!", 245, 20, 20, false)
		end
	end
)

local function toggleInventory()
	if ( exports.common:isPlayerPlaying( localPlayer ) ) then
		if ( LOCKINVENTORY ) then
			outputChatBox( "Exit your phone in order to toggle the inventory.", 245, 20, 20, false )
		else
			isVisible = not isVisible
			toggleAllControls( not isVisible, true, false )
			showCursor( isVisible, isVisible )
			CATEGORY_hovering = nil
			CATEGORY_open = nil
			DELETING = nil
			draggingWorldItem = false
		end
	end
end

addEvent( "inventory:unlock", true )
addEventHandler( "inventory:unlock", root,
	function( )
		LOCKINVENTORY = false
	end
)

addEvent( "inventory:close", true )
addEventHandler( "inventory:close", root,
	function( )
		isVisible = false
		toggleAllControls( true, true, false )
		showCursor( false, false )
		CATEGORY_hovering = nil
		CATEGORY_open = nil
		DELETING = nil
		draggingWorldItem = false
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