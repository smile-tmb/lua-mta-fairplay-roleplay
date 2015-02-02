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

local modelSets = { }

function getModelSet( id )
	return modelSets[ id ]
end

function createModelSet( make, model, year, price, gtaModelID, createdBy )
	local modelSetID = exports.database:insert_id( "INSERT INTO `vehicles_model_sets` (`make`, `model`, `year`, `price`, `gta_model_id`, `created_by`, `modified`, `created`) VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())", make, model, year, price, gtaModelID, createdBy )
	return modelSetID and cacheModelSet( modelSetID ) or false
end

function deleteModelSet( id )
	if ( exports.database:execute( "DELETE FROM `vehicles_model_sets` WHERE `id` = ?", id ) ) then
		modelSets[ id ] = nil

		return true
	end

	return false
end

function cacheModelSet( id )
	local modelSet = exports.database:query_single( "SELECT * FROM `vehicles_model_sets` WHERE `id` = ? LIMIT 1", id )
	
	if ( modelSet ) then
		modelSets[ modelSet.id ] = modelSet

		return modelSets[ modelSet.id ]
	end

	return false
end

function cacheAllModelSets( )
	local query = exports.database:query( "SELECT * FROM `vehicles_model_sets`" )
	
	if ( query ) then
		for _, modelSet in ipairs( query ) do
			modelSets[ modelSet.id ] = modelSet
		end

		return true
	end

	return false
end
addEventHandler( "onResourceStart", resourceRoot, cacheAllModelSets )