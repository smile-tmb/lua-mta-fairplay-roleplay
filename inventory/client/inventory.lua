--[[
	The MIT License (MIT)

	Copyright (c) 2014 Socialz (+ soc-i-alz GitHub organization)

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]

local screenWidth, screenHeight = guiGetScreenSize( )

local isInventoryShowing = false

local categoryBoxScale = 80
local categoryBoxSpacing = 5
local categoryBoxSpaced = categoryBoxScale + categoryBoxSpacing
local categoryBackgroundColor = tocolor( 5, 5, 5, 0.45 * 255 )
local categoryActiveColor = tocolor( 150, 150, 150, 0.5 * 255 )
local categoryHoverActiveColor = tocolor( 200, 200, 200, 0.5 * 255 )
local categoryHoverColor = tocolor( 5, 5, 5, 0.95 * 255 )
local categoryColor = tocolor( 5, 5, 5, 0.75 * 255 )

local categories = {
	{ name = "Items", value = "All your miscellaneous items are here.", type = 1 },
	{ name = "Keys", value = "All your keys are in this keychain.", type = 2 },
	{ name = "Weapons", value = "All your weapons are in here.", type = 3 },
}

local category = false

local inventoryBoxScale = 60
local inventoryBoxSpacing = 4
local inventoryBoxSpaced = inventoryBoxScale + inventoryBoxSpacing
local inventoryBackgroundColor = tocolor( 5, 5, 5, 0.55 * 255 )
local inventoryDeleteColor = tocolor( 100, 5, 5, 0.65 * 255 )
local inventoryShowColor = tocolor( 15, 15, 100, 0.65 * 255 )
local inventoryDropColor = tocolor( 5, 100, 5, 0.65 * 255 )
local inventoryColorEmpty = tocolor( 5, 5, 5, 0.45 * 255 )
local inventoryActiveColor = tocolor( 5, 5, 5, 0.85 * 255 )
local inventoryHoverColor = tocolor( 10, 10, 10, 0.8 * 255 )
local inventoryColor = tocolor( 5, 5, 5, 0.75 * 255 )
local inventoryDragAvailable = tocolor( 5, 100, 5, 0.65 * 255 )
local inventoryDragUnavailable = tocolor( 100, 5, 5, 0.65 * 255 )

local inventory = { }

local inventoryRows = 4
local inventoryColumns = 0

local tooltipSpacing = 12
local tooltipColor = tocolor( 5, 5, 5, 0.75 * 255 )
local tooltipTextColor = tocolor( 250, 250, 250, 1.0 * 255 )

local maximumTriggerDistance = 12.725

local hoveringCategory = false
local hoveringItem = false
local hoveringWorldItem = false

local dragTimer

local function dxDrawTooltip( values, x, y )
	local name = values.name or "[no title]"
	local value = values.value or false
	local output = name
	
	local width = dxGetTextWidth( output, 1, "clear" ) + ( tooltipSpacing * 2 )
	
	if ( value ) then
		width = math.max( width, dxGetTextWidth( value, 1, "clear" ) + ( tooltipSpacing * 2 ) )
		output = output .. "\n" .. value
	end
	
	local height = dxGetFontHeight( 1, "clear" )
		  height = ( value and 5 or 0 ) + height + tooltipSpacing * 2
	
	local y = y + 15
	
	local x = math.max( tooltipSpacing, math.min( x, screenWidth - width - tooltipSpacing ) )
	local y = math.max( tooltipSpacing, math.min( y, screenHeight - height - tooltipSpacing ) )
	
	dxDrawRectangle( x, y, width, height, tooltipColor )
	dxDrawText( output, x, y, x + width, y + height, tooltipTextColor, 1, "clear", "center", "center", false, false, true )
end

local function getWorldItemFromCursor( )
	local cursorX, cursorY, worldX, worldY, worldZ = getCursorPosition( )
	local cameraX, cameraY, cameraZ = getWorldFromScreenPosition( cursorX, cursorY, 0.1 )
	local collision, hitX, hitY, hitZ, hitElement = processLineOfSight( cameraX, cameraY, cameraZ, worldX, worldY, worldZ, true, true, true, true, true, true, true, nil, false, true )
	
	if ( hitElement ) and ( getElementParent( getElementParent( hitElement ) ) == getResourceRootElement( getResourceFromName( "items" ) ) ) and ( exports.common:getRealWorldItemID( hitElement ) ) then
		return hitElement
	elseif ( ( hitX ) and ( hitY ) and ( hitZ ) ) then
		hitElement = nil
		local x, y, z = nil
		local maxDistance = 0.35
		
		for _, element in ipairs( getElementsByType( "object", getResourceRootElement( getResourceFromName( "items" ) ) ) ) do
			if ( exports.common:getRealWorldItemID( hitElement ) ) and ( isElementStreamedIn( element ) ) and ( isElementOnScreen( element ) ) then
				x, y, z = getElementPosition( element )
				local distance = getDistanceBetweenPoints3D( x, y, z, hitX, hitY, hitZ )
				
				if ( distance < maxDistance ) then
					hitElement = element
					maxDistance = distance
				end
			end
		end
		
		if ( hitElement ) then
			local x, y, z = getElementPosition( localPlayer )
			
			return getDistanceBetweenPoints3D( x, y, z, getElementPosition( hitElement ) ) <= maximumTriggerDistance and hitElement
		end
	end
	
	return false
end

local function renderInventory( )
	if ( not isInventoryShowing ) or ( not isCursorShowing( ) ) then
		return
	end
	
	inventory = { }
	
	local items = exports.items:getItems( localPlayer )
	
	if ( items ) then
		for index, values in ipairs( items ) do
			if ( exports.items:getItemType( values.itemID ) == activeCategory ) then
				table.insert( inventory, values )
			end
		end
	else
		return
	end
	
	inventoryColumns = math.ceil( #inventory / inventoryRows )
	
	hoveringCategory = false
	hoveringItem = false
	
	local cursorX, cursorY, worldX, worldY, worldZ = getCursorPosition( )
		  cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
	
	local x = screenWidth - categoryBoxSpaced - categoryBoxSpacing
	local y = ( screenHeight - #categories * categoryBoxSpaced - categoryBoxSpacing ) / 2
	
	-- Category background rendering
	dxDrawRectangle( x, y, categoryBoxSpaced + categoryBoxSpacing, #categories * categoryBoxSpaced + categoryBoxSpacing, categoryBackgroundColor )
	
	-- Category rendering
	for index, values in ipairs( categories ) do
		local x = x + categoryBoxSpacing
		local y = y + categoryBoxSpacing + categoryBoxSpaced * ( index - 1 )
		
		local isHovering = exports.common:isWithin2DBounds( cursorX, cursorY, x, y, categoryBoxScale, categoryBoxScale )
		local color = isHovering and ( activeCategory == index and categoryHoverActiveColor or categoryHoverColor ) or ( activeCategory == index and categoryActiveColor or categoryColor )
		
		dxDrawRectangle( x, y, categoryBoxScale, categoryBoxScale, color )
		dxDrawImage( x, y, categoryBoxScale, categoryBoxScale, "assets/-" .. index .. ".png" )
		
		if ( isHovering ) then
			hoveringCategory = index
		end
	end
	
	local offsetX = categoryBoxSpaced + categoryBoxSpacing
	
	local bgX = screenWidth - offsetX - inventoryColumns * inventoryBoxSpaced - inventoryBoxSpacing
	local bgY = ( screenHeight - inventoryRows * inventoryBoxSpaced - inventoryBoxSpacing ) / 2
	
	if ( activeCategory ) and ( inventoryColumns > 0 ) then
		if ( not draggingItem ) then
			-- Inventory background rendering
			dxDrawRectangle( bgX, bgY, inventoryColumns * inventoryBoxSpaced + inventoryBoxSpacing, inventoryRows * inventoryBoxSpaced + inventoryBoxSpacing, categoryBackgroundColor )
		end
		
		-- Inventory items rendering
		for index = 1, inventoryColumns * inventoryRows do
			local column = math.floor( ( index - 1 ) / inventoryRows )
			local row = ( index - 1 ) % inventoryRows
			
			local x = x - ( inventoryBoxSpaced + inventoryBoxSpacing ) - column * inventoryBoxSpaced + inventoryBoxSpacing
			local y = y + row * inventoryBoxSpaced + inventoryBoxSpacing
			
			local item = inventory[ index ]
			
			if ( item ) then
				local isHovering = exports.common:isWithin2DBounds( cursorX, cursorY, x, y, inventoryBoxScale, inventoryBoxScale )
				local color = isHovering and ( getKeyState( "delete" ) and inventoryDeleteColor or ( ( ( getKeyState( "lctrl" ) ) or ( getKeyState( "rctrl" ) ) ) and inventoryDropColor or ( ( ( getKeyState( "lalt" ) ) or ( getKeyState( "ralt" ) ) ) and  inventoryShowColor or inventoryHoverColor ) ) ) or inventoryColor
				
				if ( draggingItem == index ) then
					x, y = cursorX, cursorY
					
					local cameraX, cameraY, cameraZ = getWorldFromScreenPosition( cursorX, cursorY, 0.1 )
					local collision, hitX, hitY, hitZ, hitElement = processLineOfSight( cameraX, cameraY, cameraZ, worldX, worldY, worldZ, true, true, true, true, true, false, true, false, localPlayer, false, true )
					
					if ( collision ) and ( getDistanceBetweenPoints3D( hitX, hitY, hitZ, getElementPosition( localPlayer ) ) <= maximumTriggerDistance ) then
						color = inventoryDragAvailable
					else
						color = inventoryDragUnavailable
					end
				end
				
				dxDrawRectangle( x, y, inventoryBoxScale, inventoryBoxScale, color )
				dxDrawImage( x, y, inventoryBoxScale, inventoryBoxScale, "assets/" .. item.itemID .. ( exports.items:getItemType( item.itemID ) == 3 and "_" .. exports.items:getWeaponID( item.itemValue ) or "" ) .. ".png" )
				
				if ( isHovering ) then
					hoveringItem = index
				end
				
				if ( draggingItem == index ) then
					break
				end
			else
				dxDrawRectangle( x, y, inventoryBoxScale, inventoryBoxScale, inventoryColorEmpty )
			end
		end
	end
	
	-- Hover tooltips
	if ( hoveringCategory ) then
		dxDrawTooltip( categories[ hoveringCategory ], cursorX, cursorY )
	elseif ( hoveringItem ) then
		local item = inventory[ hoveringItem ]
		local name = exports.items:getItemName( item.itemID )
		local value = tostring( item.itemValue ):len( ) > 0 and item.itemValue or false
		
		if ( exports.items:getItemType( item.itemID ) == 2 ) then
			if ( item.itemID == 6 ) then
				name = name .. " (PRN " .. ( value or "?" ) .. ")"
			elseif ( item.itemID == 7 ) then
				name = name .. " (VIN " .. ( value or "?" ) .. ")"
			end
		elseif ( exports.items:getItemType( item.itemID ) == 3 ) then
			local weaponName = exports.items:getWeaponName( value )
			
			name = name .. " (" .. weaponName .. ")"
		end
		
		value = exports.items:getItemDescription( item.itemID )
		
		dxDrawTooltip( { name = name, value = value }, cursorX, cursorY )
	end
end

local function renderWorldItems( )
	hoveringWorldItem = false
	
	if ( not isCursorShowing( ) ) or ( hoveringCategory ) or ( hoveringItem ) then
		return
	end
	
	local worldItem = getWorldItemFromCursor( )
	
	if ( worldItem ) then
		hoveringWorldItem = worldItem
		
		local cursorX, cursorY = getCursorPosition( )
			  cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
		
		local itemID = exports.common:getWorldItemID( worldItem )
		local name = exports.items:getItemName( itemID )
		local value = exports.common:getWorldItemValue( worldItem )
			  value = tostring( value ):len( ) > 0 and value or false
		
		if ( exports.items:getItemType( itemID ) == 2 ) then
			if ( itemID == 6 ) then
				name = name .. " (PRN " .. ( value or "?" ) .. ")"
			elseif ( itemID == 7 ) then
				name = name .. " (VIN " .. ( value or "?" ) .. ")"
			end
		elseif ( exports.items:getItemType( itemID ) == 3 ) then
			local weaponName = exports.items:getWeaponName( value )
			
			name = name .. " (" .. weaponName .. ")"
		end
		
		value = exports.items:getItemDescription( itemID )
		
		dxDrawTooltip( { name = name, value = value }, cursorX, cursorY )
	end
end

function toggleInventory( )
	local fn = isInventoryShowing and removeEventHandler or addEventHandler
	
	fn( "onClientHUDRender", root, renderInventory )
	
	isInventoryShowing = not isInventoryShowing
	
	showCursor( isInventoryShowing )
	
	draggingItem = false
end

addEventHandler( "onClientClick", root,
	function( button, state, cursorX, cursorY, worldX, worldY, worldZ, clickedElement )
		if ( not isInventoryShowing ) then
			return
		end
		
		if ( button == "left" ) then
			if ( state == "down" ) then
				if ( hoveringItem ) then
					if ( isTimer( dragTimer ) ) then
						resetTimer( dragTimer )
					else
						dragTimer = setTimer( function( hoveredItem )
							if ( hoveringItem == hoveredItem ) then
								draggingItem = hoveringItem
							end
						end, 185, 1, hoveringItem )
					end
				end
			else
				if ( isTimer( dragTimer ) ) then
					killTimer( dragTimer )
				end
				
				if ( draggingItem ) then
					if ( getDistanceBetweenPoints3D( worldX, worldY, worldZ, getElementPosition( localPlayer ) ) <= maximumTriggerDistance ) then
						triggerServerEvent( "items:drop", localPlayer, inventory[ draggingItem ], worldX, worldY, worldZ )
					end
					
					draggingItem = false
				elseif ( hoveringCategory ) then
					activeCategory = hoveringCategory
				elseif ( hoveringItem ) then
					local item = inventory[ hoveringItem ]
					
					if ( getKeyState( "delete" ) ) then
						triggerServerEvent( "items:delete", localPlayer, item )
					elseif ( getKeyState( "lctrl" ) ) or ( getKeyState( "rctrl" ) ) then
						local x, y, z = getElementPosition( localPlayer )
							  z = getGroundPosition( x, y, z + 2 )
						triggerServerEvent( "items:drop", localPlayer, item, x, y, z )
					elseif ( getKeyState( "lalt" ) ) or ( getKeyState( "ralt" ) ) then
						triggerServerEvent( "items:show", localPlayer, item )
					else
						triggerServerEvent( "items:use", localPlayer, item )
					end
				elseif ( hoveringWorldItem ) then
					triggerServerEvent( "items:pickup", localPlayer, hoveringWorldItem )
				end
			end
		elseif ( button == "right" ) then
			draggingItem = false
		end
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		bindKey( "I", "down", "inventory" )
		
		addEventHandler( "onClientRender", root, renderWorldItems )
	end
)

addCommandHandler( "inventory",
	function( cmd )
		if ( exports.common:isPlayerPlaying( localPlayer ) ) or ( isInventoryShowing ) then
			toggleInventory( )
		end
	end
)