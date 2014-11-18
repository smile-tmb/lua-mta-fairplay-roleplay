local obfuscate_script = false
local compile_script = obfuscate_script or false

local compiler_address = "http://luac.mtasa.com/?compile=" .. ( compile_script and 1 or 0 ) .. "&debug=0&obfuscate=" .. ( obfuscate_script and 1 or 0 )
local resource_config_file = "meta.xml"
local combined_script_file_name = "script"

addEventHandler( "onPlayerJoin", root,
	function( )
		outputChatBox( "There is nothing on this server at this time. Sorry.", source, 255, 0, 0, false )
	end
)

function load_resource( resource_name )
	local resource = getResourceFromName( resource_name )
	
	if ( resource ) then
		local resource_name = getResourceName( resource )
		
		if ( getResourceState( resource ) == "running" ) then
			stopResource( resource )
		end
		
		local resource_path = ":" .. resource_name .. "/"
		local xml_file = xmlLoadFile( resource_path .. resource_config_file )
		local script_files_to_combine = { }
		
		if ( xml_file ) then
			xmlCopyFile( xml_file, resource_path .. "meta-" .. getRealTime( ).timestamp .. ".xml" )
			
			local xml_script_children = xmlNodeGetChildren( xml_file )
			local xml_found_combined_file, xml_found_shared_content = false, false
			
			for _,xml_node in ipairs( xml_script_children ) do
				if ( xmlNodeGetName( xml_node ) == "_script" ) and ( ( xmlNodeGetAttribute( xml_node, "type" ) == "client" ) or ( xmlNodeGetAttribute( xml_node, "type" ) == "shared" ) ) then
					if ( xmlNodeGetAttribute( xml_node, "type" ) == "shared" ) then
						xml_found_shared_content = true
					end
					
					table.insert( script_files_to_combine, xmlNodeGetAttribute( xml_node, "src" ) )
					outputDebugString( xmlNodeGetAttribute( xml_node, "src" ) )
				end
				
				if ( xmlNodeGetName( xml_node ) == "script" ) and ( xmlNodeGetAttribute( xml_node, "src" ) == "script" ) then
					xml_found_combined_file = true
				end
			end
			
			if ( not xml_found_combined_file ) then
				local xml_node = xmlCreateChild( xml_file, "script" )
				
				xmlNodeSetAttribute( xml_node, "src", "script" )
				xmlNodeSetAttribute( xml_node, "type", xml_found_shared_content and "shared" or "client" )
				xmlNodeSetAttribute( xml_node, "cached", "false" )
				
				xmlSaveFile( xml_file )
			end
			
			xmlUnloadFile( xml_file )
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
						fileClose( resource_path .. client_file_path )
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
							combined_script_file_content = combined_script_file_content .. " " .. contents
							
							fileClose( client_file )
						end
					end
				end
				
				combined_script_file_content = pregReplace( combined_script_file_content, "\t", " " )
				
				while ( combined_script_file_content ) and ( combined_script_file_content:find( "  " ) ) do
					combined_script_file_content = combined_script_file_content:gsub( "  ", " " )
				end
				
				local bytes_to_read = fileGetSize( combined_script_file ) or 0
				
				outputDebugString( "Bytes to read: " .. bytes_to_read .. "." )
				
				local current_script_file_content = ""
				
				while ( not fileIsEOF( combined_script_file ) ) do
					current_script_file_content = current_script_file_content .. fileRead( combined_script_file, 500 )
				end
				
				if ( compile_script ) then
					waiting_for_compiler = true
					
					fetchRemote( compiler_address, function( data )
						outputDebugString( combined_script_file_content )
						
						combined_script_file_content = data
						
						outputDebugString( combined_script_file_content )
						
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
			outputDebugString( "No client files to compile." )
		end
		
		if ( not waiting_for_compiler ) then
			startResource( resource )
			
			if ( combined_script_file ) then
				fileClose( combined_script_file )
			end
			
			outputDebugString( "Resource \"" .. resource_name .. "\" started." )
		end
	else
		outputDebugString( "Resource could not be started.", 3 )
	end
end
addEvent( "onResourceRequestedStart", true )
addEventHandler( "onResourceRequestedStart", root, load_resource )