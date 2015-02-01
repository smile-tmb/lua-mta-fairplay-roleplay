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

local obfuscate_script = false
local compile_script = obfuscate_script or false

local compiler_address = "http://luac.mtasa.com/?compile=" .. ( compile_script and 1 or 0 ) .. "&debug=0&obfuscate=" .. ( obfuscate_script and 1 or 0 )
local resource_config_file = "meta.xml"
local combined_script_file_name = "script"

function load_resource( resource_name )
	local resource = getResourceFromName( resource_name )
	
	if ( resource ) then
		local resource_name = getResourceName( resource )
		local load_failed = false
		
		if ( getResourceState( resource ) == "running" ) then
			if ( not restartResource( resource ) ) then
				load_failed = "restartResource failed"
			end
		elseif ( getResourceState( resource ) == "loaded" ) then
			if ( not startResource( resource ) ) then
				load_failed = "startResource failed"
			end
		else
			load_failed = "unknown resource state [\"" .. getResourceState( resource ) .. "\"]"
		end

		if ( load_failed ) then
			outputDebugString( "Resource could not be started (" .. load_failed .. ").", 3 )
		end

		--[[
		local resource_path = ":" .. resource_name .. "/"
		local xml_file = xmlLoadFile( resource_path .. resource_config_file )
		local script_files_to_combine = { }
		local xml_copy
		
		if ( xml_file ) then
			xml_copy = xmlCopyFile( xml_file, resource_path .. "meta-" .. getRealTime( ).timestamp .. ".xml" )
			
			local xml_script_children = xmlNodeGetChildren( xml_file )
			local xml_found_combined_file, xml_found_shared_content = false, false
			
			for _,xml_node in ipairs( xml_script_children ) do
				if ( xmlNodeGetName( xml_node ) == "_script" ) and ( xmlNodeGetAttribute( xml_node, "type" ) == "client" ) then --or ( xmlNodeGetAttribute( xml_node, "type" ) == "shared" )
					if ( xmlNodeGetAttribute( xml_node, "type" ) == "shared" ) then
						xml_found_shared_content = true
					end
					
					table.insert( script_files_to_combine, xmlNodeGetAttribute( xml_node, "src" ) )
					--outputDebugString( xmlNodeGetAttribute( xml_node, "src" ) )
				end
				
				if ( xmlNodeGetName( xml_node ) == "script" ) and ( xmlNodeGetAttribute( xml_node, "src" ) == "script" ) then
					xml_found_combined_file = true
				end
			end
			
			if ( not xml_found_combined_file ) then
				local xml_node = xmlCreateChild( xml_file, "script" )
				
				xmlNodeSetAttribute( xml_node, "src", "script" )
				xmlNodeSetAttribute( xml_node, "type", xml_found_shared_content and "shared" or "client" )
				xmlNodeSetAttribute( xml_node, "cache", "false" )
			end
		else
			outputDebugString( "Could not find or read configuration file.", 3 )
		end
		
		local script_files = { }
		
		for _,client_file_path in pairs( script_files_to_combine ) do
			if ( fileExists( resource_path .. client_file_path ) ) then
				local client_file = fileOpen( resource_path .. client_file_path )
				
				if ( client_file ) then
					if ( fileGetSize( client_file ) > 1 ) then
						table.insert( script_files, client_file )
					else
						fileClose( client_file )
					end
				else
					outputDebugString( "Could not read file via path \"" .. resource_path .. client_file_path .. "\".", 2 )
				end
			else
				outputDebugString( "Could not find file via path \"" .. resource_path .. client_file_path .. "\".", 2 )
			end
		end
		
		waiting_for_compiler = false
		
		if ( #script_files > 0 ) then
			xmlSaveFile( xml_copy )
			xmlUnloadFile( xml_copy )
			
			xmlSaveFile( xml_file )
			xmlUnloadFile( xml_file )
			
			local combined_script_file = fileExists( resource_path .. combined_script_file_name ) and fileOpen( resource_path .. combined_script_file_name ) or false
			
			if ( not combined_script_file ) then
				combined_script_file = fileCreate( resource_path .. combined_script_file_name )
				
				if ( not combined_script_file ) then
					outputDebugString( "Could not create combined client file.", 3 )
					
					return
				end
			end
			
			if ( combined_script_file ) then
				local combined_script_file_content = ""
				
				for _,client_file in pairs( script_files ) do
					if ( client_file ) then
						local contents = fileRead( client_file, fileGetSize( client_file ) )
						
						if ( contents ) then
							combined_script_file_content = combined_script_file_content .. "\r\n" .. contents
							
							fileClose( client_file )
						end
					end
				end
				
				combined_script_file_content = pregReplace( combined_script_file_content, "\t", " " )
				combined_script_file_content = pregReplace( combined_script_file_content, "\r\n\r\n", "\r\n" )
				
				while ( combined_script_file_content ) and ( combined_script_file_content:find( "  " ) ) do
					combined_script_file_content = combined_script_file_content:gsub( "  ", " " )
				end
				
				local bytes_to_read = fileGetSize( combined_script_file ) or 0
				
				outputDebugString( "Bytes to read: " .. bytes_to_read .. "." )
				
				local current_script_file_content = ""
				
				while ( not fileIsEOF( combined_script_file ) ) do
					current_script_file_content = current_script_file_content .. fileRead( combined_script_file, 500 )
				end
				
				combined_script_file_content = tostring( combined_script_file_content )
				
				if ( compile_script ) then
					waiting_for_compiler = true
					
					fetchRemote( compiler_address, function( data )
						--outputDebugString( combined_script_file_content )
						
						combined_script_file_content = data
						
						--outputDebugString( combined_script_file_content )
						
						local current_checksum = md5( current_script_file_content )
						local new_checksum = md5( combined_script_file_content )
						
						if ( new_checksum ~= current_checksum ) then
							combined_script_file = fileCreate( resource_path .. combined_script_file_name )
							
							if ( combined_script_file ) then
								fileWrite( combined_script_file, combined_script_file_content )
								fileFlush( combined_script_file )
							else
								outputDebugString( "Welp, something went wrong when cleaning file.", 3 )
							end
						else
							outputDebugString( "Checksums match (no modification found) [" .. current_checksum .. "]." )
						end
						
						fileClose( combined_script_file )
						
						startResource( resource )
						
						outputDebugString( "Resource \"" .. resource_name .. "\" started." )
					end, combined_script_file_content, true )
				else
					local current_checksum = md5( current_script_file_content )
					local new_checksum = md5( combined_script_file_content )
					
					if ( new_checksum ~= current_checksum ) then
						combined_script_file = fileCreate( resource_path .. combined_script_file_name )
						
						if ( combined_script_file ) then
							fileWrite( combined_script_file, combined_script_file_content )
							fileFlush( combined_script_file )
						else
							outputDebugString( "Welp, something went wrong when cleaning file.", 3 )
						end
					else
						outputDebugString( "Checksums match (no modification found) [" .. current_checksum .. "]." )
					end
				end
			else
				outputDebugString( "Could not load the combined client file.", 3 )
			end
		else
			xmlUnloadFile( xml_copy )
			xmlUnloadFile( xml_file )
			outputDebugString( "No client files to compile." )
		end
		
		if ( not waiting_for_compiler ) then
			startResource( resource )
			
			if ( combined_script_file ) then
				fileClose( combined_script_file )
			end
			
			outputDebugString( "Resource \"" .. resource_name .. "\" started." )
		end
		]]
	else
		outputDebugString( "Resource could not be started (not found).", 3 )
	end
end
addEvent( "onResourceRequestedStart", true )
addEventHandler( "onResourceRequestedStart", root, load_resource )