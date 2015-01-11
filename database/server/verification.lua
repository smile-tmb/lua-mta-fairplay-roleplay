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

database.configuration.automated_resources = { accounts = { "accounts", "characters" }, admin = { "ticket_logs" }, chat = { "languages" }, items = { "inventory", "worlditems" }, vehicles = { "vehicles" } }
database.configuration.default_charset = get( "default_charset" ) or "utf8"
database.configuration.default_engine = get( "default_engine" ) or "InnoDB"
database.utility = { }
database.verification = {
	-- name, type, length, default, is_unsigned, is_null, is_auto_increment, key_type
	accounts = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "username", type = "varchar", length = 25, default = "" },
		{ name = "password", type = "varchar", length = 1000, default = "" },
		{ name = "level", type = "tinyint", length = 3, default = 0 },
		{ name = "tutorial", type = "tinyint", length = 1, default = 0 },
		{ name = "tutorial_date", type = "timestamp", default = "0000-00-00 00:00:00" },
		{ name = "is_deleted", type = "tinyint", length = 1, default = 0 },
		{ name = "last_login", type = "timestamp", default = "0000-00-00 00:00:00" },
		{ name = "last_action", type = "timestamp", default = "0000-00-00 00:00:00" },
		{ name = "last_ip", type = "varchar", length = 128, default = "0.0.0.0" },
		{ name = "last_serial", type = "varchar", length = 32, default = "13371337133713371337133713371337" }
	},
	characters = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "account", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "skin_id", type = "smallint", length = 3, default = 0, is_unsigned = true },
		{ name = "name", type = "varchar", length = 255, default = "" },
		{ name = "gender", type = "varchar", length = 255, default = "" },
		{ name = "skin_color", type = "varchar", length = 255, default = "" },
		{ name = "date_of_birth", type = "timestamp", default = "0000-00-00 00:00:00" },
		{ name = "origin", type = "varchar", length = 255, default = "" },
		{ name = "look", type = "varchar", length = 255, default = "" },
		{ name = "pos_x", type = "float", default = 0 },
		{ name = "pos_y", type = "float", default = 0 },
		{ name = "pos_z", type = "float", default = 0 },
		{ name = "rotation", type = "float", default = 0 },
		{ name = "interior", type = "tinyint", length = 3, default = 0, is_unsigned = true },
		{ name = "dimension", type = "smallint", length = 5, default = 0, is_unsigned = true },
		{ name = "health", type = "smallint", length = 3, default = 100, is_unsigned = true },
		{ name = "armor", type = "smallint", length = 3, default = 0, is_unsigned = true },
		{ name = "is_dead", type = "smallint", length = 1, default = 0, is_unsigned = true },
		{ name = "cause_of_death", type = "text" },
		{ name = "last_played", type = "timestamp", default = "0000-00-00 00:00:00" },
		{ name = "created_time", type = "timestamp", default = "CURRENT_TIMESTAMP" }
	},
	inventory = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "owner_id", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "item_id", type = "smallint", length = 3, default = 0, is_unsigned = true },
		{ name = "item_value", type = "varchar", length = 1000, default = "" }
	},
	languages = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "character_id", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "language_1", type = "smallint", length = 3, default = 1, is_unsigned = true },
		{ name = "language_2", type = "smallint", length = 3, default = 0, is_unsigned = true },
		{ name = "language_3", type = "smallint", length = 3, default = 0, is_unsigned = true },
		{ name = "skill_1", type = "smallint", length = 3, default = 100, is_unsigned = true },
		{ name = "skill_2", type = "smallint", length = 3, default = 0, is_unsigned = true },
		{ name = "skill_3", type = "smallint", length = 3, default = 0, is_unsigned = true }
	},
	ticket_logs = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "source_character_id", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "target_character_id", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "message", type = "text" },
		{ name = "type", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "players", type = "varchar", length = 1000, default = "[ [ ] ]" },
		{ name = "location", type = "varchar", length = 255, default = "N/A" },
		{ name = "time", type = "varchar", length = 255, default = "N/A" },
		{ name = "assigned_time", type = "timestamp", default = "0000-00-00 00:00:00" },
		{ name = "assigned_to", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "closed_time", type = "timestamp", default = "0000-00-00 00:00:00" },
		{ name = "closed_state", type = "tinyint", length = 3, default = 0, is_unsigned = true }
	},
	vehicles = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "model_id", type = "smallint", length = 3, default = 0, is_unsigned = true },
		{ name = "pos_x", type = "float", default = 0 },
		{ name = "pos_y", type = "float", default = 0 },
		{ name = "pos_z", type = "float", default = 0 },
		{ name = "rot_x", type = "float", default = 0 },
		{ name = "rot_y", type = "float", default = 0 },
		{ name = "rot_z", type = "float", default = 0 },
		{ name = "interior", type = "tinyint", length = 3, default = 0, is_unsigned = true },
		{ name = "dimension", type = "smallint", length = 5, default = 0, is_unsigned = true },
		{ name = "respawn_pos_x", type = "float", default = 0 },
		{ name = "respawn_pos_y", type = "float", default = 0 },
		{ name = "respawn_pos_z", type = "float", default = 0 },
		{ name = "respawn_rot_x", type = "float", default = 0 },
		{ name = "respawn_rot_y", type = "float", default = 0 },
		{ name = "respawn_rot_z", type = "float", default = 0 },
		{ name = "respawn_interior", type = "tinyint", length = 3, default = 0, is_unsigned = true },
		{ name = "respawn_dimension", type = "smallint", length = 5, default = 0, is_unsigned = true },
		{ name = "numberplate", type = "varchar", length = 10, default = "UNd3F1N3D" },
		{ name = "variant_1", type = "tinyint", length = 3, default = 255, is_unsigned = true },
		{ name = "variant_2", type = "tinyint", length = 3, default = 255, is_unsigned = true },
		{ name = "owner_id", type = "int", length = 11, default = 0 },
		{ name = "health", type = "smallint", length = 4, default = 1000, is_unsigned = true },
		{ name = "color", type = "varchar", length = 255, default = "[ [ 0, 0, 0 ], [ 0, 0, 0 ], [ 0, 0, 0], [ 0, 0, 0 ] ]" },
		{ name = "headlight_color", type = "varchar", length = 255, default = "[ [ 0, 0, 0 ] ]" },
		{ name = "headlight_state", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "door_states", type = "varchar", length = 255, default = "[ [ 0, 0, 0, 0, 0, 0 ] ]" },
		{ name = "panel_states", type = "varchar", length = 255, default = "[ [ 0, 0, 0, 0, 0, 0 ] ]" },
		{ name = "is_locked", type = "tinyint", length = 1, default = 1, is_unsigned = true },
		{ name = "is_engine_on", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "is_deleted", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "is_broken", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "is_bulletproof", type = "tinyint", length = 1, default = 0, is_unsigned = true },
		{ name = "created_time", type = "timestamp", default = "CURRENT_TIMESTAMP" },
		{ name = "created_by", type = "int", length = 11, default = 0, is_unsigned = true }
	},
	worlditems = {
		{ name = "id", type = "int", length = 10, is_unsigned = true, is_auto_increment = true, key_type = "primary" },
		{ name = "item_id", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "value", type = "varchar", length = 1000, default = "" },
		{ name = "pos_x", type = "float", default = 0 },
		{ name = "pos_y", type = "float", default = 0 },
		{ name = "pos_z", type = "float", default = 0 },
		{ name = "rot_x", type = "float", default = 0 },
		{ name = "rot_y", type = "float", default = 0 },
		{ name = "rot_z", type = "float", default = 0 },
		{ name = "interior", type = "tinyint", length = 3, default = 0, is_unsigned = true },
		{ name = "dimension", type = "smallint", length = 5, default = 0, is_unsigned = true },
		{ name = "ringtone_id", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "messagetone_id", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "user_id", type = "int", length = 10, default = 0, is_unsigned = true },
		{ name = "protection", type = "int", length = 10, default = 0 },
		{ name = "created_time", type = "timestamp", default = "CURRENT_TIMESTAMP" }
	}
}

database.utility.keys = { unique = true, primary = true, index = true }
function getFormattedKeyType( keyValue, keyType )
	if ( keyValue ) and ( database.utility.keys[ keyType ] ) then
		return "\r\n" .. ( keyType ~= "index" and keyType:upper( ) .. " " or "" ) .. "KEY (`" .. keyValue .. "`),"
	end
	return ""
end

function verify_table( tableName )
	local tableName = escape_string( tableName, "char_digit_special" )
	if ( tableName ) and ( database.verification[ tableName ] ) then
		local query = query( "SELECT 1 FROM `" .. tableName .. "`" )
		if ( query ) then
			return true, 0
		else
			outputDebugString( "DATABASE: Don't mind the warning messages above; verify_table is running right now." )
			
			local query_string = "CREATE TABLE IF NOT EXISTS `" .. tableName .. "` ("
			
			for columnID, columnData in ipairs( database.verification[ tableName ] ) do
				query_string = query_string .. "\r\n`" .. columnData.name .. "` " .. columnData.type .. ( columnData.length and "(" .. columnData.length .. ")" or "" ) .. ( columnData.is_unsigned and " unsigned" or "" ) .. " " .. ( columnData.is_null and "NULL" or "NOT NULL" ) .. ( columnData.default and " DEFAULT '" .. columnData.default .. "'" or "" ) .. ( columnData.is_auto_increment and " AUTO_INCREMENT" or "" ) .. ( #database.verification[ tableName ] ~= columnID and "," or "" ) .. getFormattedKeyType( columnData.name, columnData.key_type )
			end
			
			query_string = query_string .. "\r\n) ENGINE=" .. database.configuration.default_engine .. " DEFAULT CHARSET=" .. database.configuration.default_charset .. ";"
			
			if ( execute( query_string ) ) then
				outputDebugString( "DATABASE: Created table '" .. tableName .. "'." )
				return true, 2
			else
				outputDebugString( "DATABASE: Unable to create table '" .. tableName .. "'.", 2 )
				return false, 2
			end
			
			return false
		end
	end
	return false, 1
end

addEventHandler( "onResourcePreStart", root,
	function( resource )
		if ( database.configuration.automated_resources[ getResourceName( resource ) ] ) then
			outputDebugString( "DATABASE: Verification check will be ran on just started '" .. getResourceName( resource ) .. "' resource." )
			
			for _,database in ipairs( database.configuration.automated_resources[ getResourceName( resource ) ] ) do
				local _return, _code = verify_table( database )
				if ( _return ) and ( _code > 0 ) then
					outputDebugString( "DATABASE: Verification check completed for \"" .. database .. "\": database created." )
				else
					--outputDebugString( "DATABASE: Verification check completed for \"" .. database .. "\": database wasn't created, because it already exists, most probably." )
				end
			end
		end
	end
)