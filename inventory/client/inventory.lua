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
local inventoryColorEmpty = tocolor( 5, 5, 5, 0.45 * 255 )
local inventoryActiveColor = tocolor( 5, 5, 5, 0.85 * 255 )
local inventoryHoverColor = tocolor( 10, 10, 10, 0.8 * 255 )
local inventoryColor = tocolor( 5, 5, 5, 0.75 * 255 )

local inventory = { }

local inventoryRows = 4
local inventoryColumns = 0

local tooltipSpacing = 12
local tooltipColor = tocolor( 5, 5, 5, 0.75 * 255 )
local tooltipTextColor = tocolor( 250, 250, 250, 1.0 * 255 )

local hoveringCategory = false
local hoveringItem = false

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

function renderInventory( )
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
	
	local cursorX, cursorY = getCursorPosition( )
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
		-- Inventory background rendering
		dxDrawRectangle( bgX, bgY, inventoryColumns * inventoryBoxSpaced + inventoryBoxSpacing, inventoryRows * inventoryBoxSpaced + inventoryBoxSpacing, categoryBackgroundColor )
		
		-- Inventory items rendering
		for index = 1, inventoryColumns * inventoryRows do
			local column = math.floor( ( index - 1 ) / inventoryRows )
			local row = ( index - 1 ) % inventoryRows
			
			local x = x - ( inventoryBoxSpaced + inventoryBoxSpacing ) - column * inventoryBoxSpaced + inventoryBoxSpacing
			local y = y + row * inventoryBoxSpaced + inventoryBoxSpacing
			
			local item = inventory[ index ]
			
			if ( item ) then
				local isHovering = exports.common:isWithin2DBounds( cursorX, cursorY, x, y, inventoryBoxScale, inventoryBoxScale )
				local color = isHovering and inventoryHoverColor or inventoryColor
				
				dxDrawRectangle( x, y, inventoryBoxScale, inventoryBoxScale, color )
				dxDrawImage( x, y, inventoryBoxScale, inventoryBoxScale, "assets/" .. item.itemID .. ( exports.items:getItemType( item.itemID ) == 3 and "_" .. exports.items:getWeaponID( item.value ) or "" ) .. ".png" )
				
				if ( isHovering ) then
					hoveringItem = index
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
		local value = item.value:len( ) > 0 and item.value or false
		
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

function toggleInventory( )
	local fn = isInventoryShowing and removeEventHandler or addEventHandler
	
	fn( "onClientHUDRender", root, renderInventory )
	
	isInventoryShowing = not isInventoryShowing
end

addEventHandler( "onClientClick", root,
	function( button, state, cursorX, cursorY, worldX, worldY, worldZ )
		if ( button == "left" ) and ( state == "down" ) then
			if ( hoveringCategory ) then
				activeCategory = hoveringCategory
			elseif ( hoveringItem ) then
				triggerServerEvent( "items:use", localPlayer, inventory[ hoveringItem ].id )
			end
		end
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		bindKey( "I", "down", "inventory" )
		
		toggleInventory( )
	end
)

addCommandHandler( "inventory",
	function( cmd )
		if ( getElementData( localPlayer, "player:playing" ) ) or ( isInventoryShowing ) then
			toggleInventory( )
		end
	end
)