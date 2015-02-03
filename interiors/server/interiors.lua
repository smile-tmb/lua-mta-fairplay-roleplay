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

local interiors = { }

_get = get
function get( id )
	return interiors[ id ] or false
end

function create( startX, startY, startZ, startInterior, startDimension, targetX, targetY, targetZ, targetInterior, targetDimension, name, type, price, createdBy )
	local id = exports.database:insert_id( "INSERT INTO `interiors` (`pos_x`, `pos_y`, `pos_z`, `interior`, `dimension`, `target_pos_x`, `target_pos_y`, `target_pos_z`, `target_interior`, `target_dimension`, `name`, `type`, `price`, `created_by`, `created`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())", startX or 0, startY or 0, startZ or 0, startInterior or 0, startDimension or 0, targetX or 0, targetY or 0, targetZ or 0, targetInterior or 0, targetDimension or 0, name or "", type or 1, price or 0, createdBy or 0 )

	if ( id ) then
		return load( id, true )
	end
end

function delete( id )
	if ( get( id ) ) then
		if ( unload( id ) ) then
			if ( exports.database:execute( "DELETE FROM `interiors` WHERE `id` = ?", id ) ) then
				return true
			else
				load( id )
			end
		end
	end

	return false
end

function load( id, loadFromDatabase )
	local data = loadFromDatabase and exports.database:query_single( "SELECT * FROM `interiors` WHERE `id` = ? LIMIT 1", id ) or get( id )

	if ( data ) then
		local entranceInterior = createPickup( data.pos_x, data.pos_y, data.pos_z )
		setElementInterior( entranceInterior, data.interior )
		setElementDimension( entranceInterior, data.dimension )

		if ( isElement( entranceInterior ) ) then
			exports.security:modifyElementData( entranceInterior, "interior:id", data.id, true )
			exports.security:modifyElementData( entranceInterior, "interior:type", data.type, true )
			exports.security:modifyElementData( entranceInterior, "interior:entrance", true, true )

			local exitInterior = createPickup( data.pos_x, data.pos_y, data.pos_z )
			setElementInterior( exitInterior, data.interior )
			setElementDimension( exitInterior, data.dimension )

			if ( isElement( exitInterior ) ) then
				exports.security:modifyElementData( exitInterior, "interior:id", data.id, true )
				exports.security:modifyElementData( exitInterior, "interior:type", data.type, true )

				setElementParent( exitInterior, entranceInterior )

				interiors[ data.id ] = data
				interiors[ data.id ].entrance = entranceInterior
				interiors[ data.id ].exit = exitInterior

				return entranceInterior, exitInterior
			else
				destroyElement( entranceInterior )
			end
		end
	end

	return false
end

function unload( id )
	local interior = get( id )

	if ( isElement( interior.entrance ) ) then
		destroyElement( interior.entrance )
	end

	if ( isElement( interior.exit ) ) then
		destroyElement( interior.exit )
	end
end