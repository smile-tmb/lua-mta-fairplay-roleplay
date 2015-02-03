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

local shops = { }
local threads = { }

local loadingShopsGlobalID
local shopsToLoadCount = 0
local maximumClickDistance = 12.5

_get = get
function get( id )
	return shops[ id ] or false
end

function create( x, y, z, interior, dimension, rotation, name, type, modelID, createdBy )
	local id = exports.database:insert_id( "INSERT INTO `shops` (`pos_x`, `pos_y`, `pos_z`, `interior`, `dimension`, `rotation`, `name`, `type`, `model_id`, `created_by`, `created`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())", x or 0, y or 0, z or 0, interior or 0, dimension or 0, rotation or 0, name or "", type or 1, modelID or 0, createdBy or 0 )

	if ( id ) then
		return load( id, true )
	end
end

function delete( id )
	if ( get( id ) ) then
		if ( unload( id ) ) then
			if ( exports.database:execute( "DELETE FROM `shops` WHERE `id` = ?", id ) ) then
				return true
			else
				load( id )
			end
		end
	end

	return false
end

function load( data, loadFromDatabase )
	local data = type( data ) == "table" and data or ( loadFromDatabase and exports.database:query_single( "SELECT * FROM `shops` WHERE `id` = ? LIMIT 1", data ) or get( data ) )

	if ( data ) then
		local shop = createPed( data.model_id, data.pos_x, data.pos_y, data.pos_z, data.rotation, false )

		if ( isElement( shop ) ) then
			setElementInterior( shop, data.interior )
			setElementDimension( shop, data.dimension )

			exports.security:modifyElementData( shop, "shop:id", data.id, true )
			exports.security:modifyElementData( shop, "shop:type", data.type, true )

			shops[ data.id ] = data
			shops[ data.id ].ped = shop

			return shop
		end
	end

	return false
end

function unload( id )
	local shop = get( id )

	if ( shop ) then
		if ( isElement( shop.ped ) ) then
			destroyElement( shop.ped )
		end

		return true
	end

	return false
end

function loadAllShops( )
	loadingShopsGlobalID = exports.messages:createGlobalMessage( "Loading shops. Please wait.", "shops-loading", true, false )
	
	for _, shop in pairs( shops ) do
		unload( shop.id )
	end
	
	local query = exports.database:query( "SELECT * FROM `shops` WHERE `is_deleted` = '0' ORDER BY `id`" )
	
	if ( query ) then
		shopsToLoadCount = #query
		
		for _, shop in ipairs( query ) do
			local loadCoroutine = coroutine.create( load )
			coroutine.resume( loadCoroutine, shop, false, true )
			table.insert( threads, loadCoroutine )
		end
		
		setTimer( resumeCoroutines, 1000, 4 )
	end
end
addEventHandler( "onResourceStart", resourceRoot, loadAllShops )

function resumeCoroutines( )
	for _, loadCoroutine in ipairs( threads ) do
		coroutine.resume( loadCoroutine )
	end
	
	if ( exports.common:count( shops ) >= shopsToLoadCount ) then
		exports.messages:destroyGlobalMessage( loadingShopsGlobalID )
	end
end

addEventHandler( "onElementClicked", root,
	function( mouseButton, buttonState, player )
		local id = exports.common:getShopID( source )
		local x, y, z = getElementPosition( player )

		if ( id ) and 
		   ( getElementType( source ) == "ped" ) and 
		   ( getElementInterior( player ) == getElementInterior( source ) ) and 
		   ( getElementDimension( player ) == getElementDimension( source ) ) and 
		   ( getDistanceBetweenPoints3D( x, y, z, getElementPosition( source ) ) <= maximumClickDistance ) then
			triggerClientEvent( player, "shops:open", player, get( id ) )
		end
	end
)

addEvent( "shops:purchase", true )
addEventHandler( "shops:purchase", root,
	function( shopID, sectionID, itemID )
		if ( source ~= client ) then
			return
		end

		local shop = get( shopID )

		if ( shop ) then
			local shopItem = getShopItem( shopID, itemID, sectionID )

			if ( shopItem ) then
				if ( exports.bank:takeMoney( client, shopItem.price ) ) then
					if ( exports.items:giveItem( client, itemID, exports.items:getItemValue( itemID ) ) ) then
						outputChatBox( "You purchased a " .. exports.items:getItemName( itemID ) .. " for $" .. exports.common:formatMoney( shopItem.price ) .. ".", 95, 230, 95 )
					else
						outputChatBox( "Could not purchase this item, please try again.", 95, 230, 95 )
						exports.bank:giveMoney( client, shopItem.price )
					end
				end
			end
		end
	end
)