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

local maintenanceStatus, overloadedStatus = false, false

function isServerInMaintenance( )
	return maintenanceStatus
end

function isServerOverloaded( )
	return overloadedStatus
end

addEvent( "admin:update_server_status", true )
addEventHandler( "admin:update_server_status", root,
	function( maintenance, overloaded )
		maintenanceStatus = maintenance
		overloadedStatus = overloaded
		
		if ( maintenance ) then
			exports.messages:createMessage( "Server is currently in maintenance / about to restart. Use of some features is limited or slowed down to improve performance.", "server-maintenance" )
		end
		
		if ( overloaded ) then
			exports.messages:createMessage( "Server is currently under heavy load. Use of some features is limited or slowed down to improve performance.", "server-overloaded" )
		end
	end
)