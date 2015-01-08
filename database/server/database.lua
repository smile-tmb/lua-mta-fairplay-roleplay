database = { }
database.queue = { }

database.configuration = { }
database.configuration.database_type = get( "connection_type" ) or "mysql"
database.configuration.database_file = get( "database_file" ) or "database"
database.configuration.database_batch = get( "database_batch" ) or 0
database.configuration.database_log = get( "database_log" ) or 1
database.configuration.database_tag = get( "database_tag" ) or "script"

database.configuration.hostname = get( "hostname" ) or "127.0.0.1"
database.configuration.username = get( "username" ) or "root"
database.configuration.password = get( "password" ) or "q2B6ZFHC"
database.configuration.database = get( "database" ) or "fairplay_rp"

database.connection = nil

local patterns = {
	-- gsub pattern, strip double/triple/... whitespaces
	[ "all_no_double" ] 		= { "[^%a%d%s%.%-%_%:%,%;]", true },
	[ "all" ] 					= { "[^%a%d%s%.%-%_%:%,%;]" },
	[ "account" ]				= { "[^%a%d%.%-%_%!%?]" },
	[ "character" ]				= { "[^%a%d%s%-]" },
	[ "digit" ] 				= { "[^%d]" },
	[ "char_digit" ] 			= { "[^%a%d]" },
	[ "char_digit_special" ]	= { "[^%a%d%_]" },
	[ "less_no_double" ] 		= { "[^%a%d%s]", true },
	[ "less" ] 					= { "[^%a%d%s]" },
}

local function connect( )
	database.queue.connection = dbConnect( database.configuration.database_type, ( database.configuration.database_type == "sqlite" and database.configuration.database_file or "dbname=" .. database.configuration.database .. ";host=" .. database.configuration.hostname ), ( database.configuration.database_type == "sqlite" and "" or database.configuration.username ), ( database.configuration.database_type == "sqlite" and "" or database.configuration.password ), "share=1;batch=" .. database.configuration.database_batch .. ";log=" .. database.configuration.database_log .. ";tag=" .. database.configuration.database_tag )
	
	if ( database.queue.connection ) then
		database.connection = database.queue.connection
		database.queue.connection = nil
		outputDebugString( "DATABASE: Database connection initialized." )
		
		return database.connection
	end
	
	outputDebugString( "DATABASE: Database connection could not be initialized.", 2 )
	
	return false
end
addEventHandler( "onResourceStart", resourceRoot, connect )

function disconnect( queueRestart )
	if ( database.connection ) then
		destroyElement( database.connection )
		database.connection = nil
		
		outputDebugString( "DATABASE: Database connection destroyed." )
		
		if ( queueRestart == true ) then
			outputDebugString( "DATABASE: Database connection restart pending." )
			connect( )
		end
		
		return true
	end
	
	--outputDebugString( "DATABASE: Database connection is not alive and could not be destroyed.", 2 )
	
	return false
end
addEventHandler( "onResourceStop", resourceRoot, disconnect )

function ping( )
	if ( database.connection ) and ( query( "SELECT 1" ) ) then return true end
	return false
end

function query( queryString, ... )
	if ( not queryString ) then
		outputDebugString( "DATABASE: Database query string missing.", 1 )
		return false, 1
	end
	
	if ( database.connection ) then
		local query = (...) and dbQuery( database.connection, queryString, ... ) or dbQuery( database.connection, queryString )
		
		if ( query ) then
			local result, num_affected_rows, last_insert_id = dbPoll( query, -1 )
			
			if ( result == false ) then
				local error_code, error_msg = num_affected_rows, last_insert_id
				
				dbFree( query )
				outputDebugString( "DATABASE: Database query failed - (errno " .. error_code .. "; error: " .. error_msg .. ").", 1 )
				
				return false
			else
				return result, num_affected_rows, last_insert_id
			end
		end
	end
	
	return false
end

function query_single( queryString, ... )
	local result, num_affected_rows, last_insert_id = query( queryString, ... )
	
	if ( result ) and ( num_affected_rows > 0 ) then
		return result[ 1 ] or result, num_affected_rows, last_insert_id
	end
	
	return false
end

function execute( queryString, ... )
	local parameters = { ... }
	local possibleHandler = parameters[ 1 ]
	
	if ( not queryString ) then
		outputDebugString( "DATABASE: Database query string missing.", 1 )
		return false, 1
	end
	
	if ( database.connection ) then
		local query = (...) and dbExec( database.connection, queryString, ... ) or dbExec( database.connection, queryString )
		
		if ( query ) then
			return true
		end
	end
	
	return false
end

function insert_id( queryString, ... )
	local result, _, last_insert_id = query( queryString, ... )
	
	if ( result ) then
		return last_insert_id
	end
	
	return false
end

function free_result( queryHandler )
	if ( not queryHandler ) then
		outputDebugString( "DATABASE: Database query handler missing.", 1 )
		return false, 1
	end
	
	if ( dbFree( queryHandler ) ) then
		return true
	end
	
	return false
end

function escape_string( string, caution )
	if ( not string ) then
		outputDebugString( "DATABASE: String-to-be-escaped is missing.", 1 )
		return false, 1
	end
	
	local string, caution = tostring( string ), ( ( caution and patterns[ caution ] ) and caution or "all_no_double" )
	
	if ( patterns[ caution ][ 2 ] ) then
		while string:find( "  " ) do
			string = string:gsub( "  ", " " )
		end
	end
	
	return ( tonumber( tostring( string:gsub( patterns[ caution ][ 1 ], "" ) ) ) and tonumber( tostring( string:gsub( patterns[ caution ][ 1 ], "" ) ) ) or tostring( string:gsub( patterns[ caution ][ 1 ], "" ) ) )
end
