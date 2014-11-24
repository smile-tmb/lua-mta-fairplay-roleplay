local screenWidth, screenHeight = guiGetScreenSize( )
local accounts_login_view = {
	button = { },
	label = { },
	edit = { }
}

local minimumUsernameLength = 2
local maximumUsernameLength = 30

local minimumPasswordLength = 8
local maximumPasswordLength = 100

function showLoginMenu( forceClose )
	if ( isElement( accounts_login_view.window ) ) then
		destroyElement( accounts_login_view.window )
		guiSetInputEnabled( false )
	end
	
	if ( forceClose ) then
		return
	end
	
	guiSetInputEnabled( true )
	
	accounts_login_view.window = guiCreateWindow( ( screenWidth - 273 ) / 2, ( screenHeight - 310 ) / 2, 273, 310, "FairPlay Gaming", false )
	guiWindowSetSizable( accounts_login_view.window, false )
	guiSetAlpha( accounts_login_view.window, 0.8725 )

	accounts_login_view.label[ 1 ] = guiCreateLabel(18, 38, 238, 39, "Welcome to FairPlay Gaming. Please log in or register using the form below.", false, accounts_login_view.window )
	guiSetFont( accounts_login_view.label[ 1 ], "default-bold-small" )
	guiLabelSetHorizontalAlign( accounts_login_view.label[ 1 ], "left", true )
	
	accounts_login_view.label[ 2 ] = guiCreateLabel( 17, 87, 238, 14, "Username", false, accounts_login_view.window )
	guiSetFont( accounts_login_view.label[ 2 ], "default-bold-small" )
	
	accounts_login_view.label[ 3 ] = guiCreateLabel( 18, 150, 238, 14, "Password", false, accounts_login_view.window )
	guiSetFont( accounts_login_view.label[ 3 ], "default-bold-small" )
	
	accounts_login_view.edit.username = guiCreateEdit( 17, 111, 239, 29, "", false, accounts_login_view.window )
	guiEditSetMaxLength( accounts_login_view.edit.username, maximumUsernameLength )
	
	accounts_login_view.edit.password = guiCreateEdit( 17, 174, 239, 29, "", false, accounts_login_view.window )
	guiSetEnabled( accounts_login_view.edit.password, false )
	guiEditSetMasked( accounts_login_view.edit.password, true )
	guiEditSetMaxLength( accounts_login_view.edit.password, maximumPasswordLength )
	
	accounts_login_view.button.login = guiCreateButton( 17, 221, 238, 31, "Log in", false, accounts_login_view.window )
	guiSetEnabled( accounts_login_view.button.login, false )
	
	accounts_login_view.button.register = guiCreateButton( 18, 262, 238, 31, "Register", false, accounts_login_view.window )
	guiSetEnabled( accounts_login_view.button.register, false )
	
	addEventHandler( "onClientGUIChanged", accounts_login_view.edit.username,
		function( )
			if ( guiGetText( accounts_login_view.edit.username ):len( ) >= minimumUsernameLength ) then
				guiSetEnabled( accounts_login_view.edit.password, true )
			else
				guiSetEnabled( accounts_login_view.edit.password, false )
			end
		end
	)
	
	addEventHandler( "onClientGUIChanged", accounts_login_view.edit.password,
		function( )
			if ( guiGetText( accounts_login_view.edit.password ):len( ) >= minimumPasswordLength ) then
				guiSetEnabled( accounts_login_view.button.login, true )
				guiSetEnabled( accounts_login_view.button.register, true )
			else
				guiSetEnabled( accounts_login_view.button.login, false )
				guiSetEnabled( accounts_login_view.button.register, false )
			end
		end
	)
	
	function processLogin( )
		local username = guiGetText( accounts_login_view.edit.username )
		local password = guiGetText( accounts_login_view.edit.password )
		
		if ( username:len( ) >= minimumUsernameLength ) then
			if ( username:len( ) <= maximumUsernameLength ) then
				if ( not password:find( username ) ) then
					if ( password:len( ) >= minimumPasswordLength ) then
						if ( password:len( ) <= maximumPasswordLength ) then
							exports.messages:createMessage( "Logging in, please wait.", "login", nil, true )
							guiSetEnabled( accounts_login_view.window, false )
							
							triggerServerEvent( "accounts:login", localPlayer, username, password )
						end
					end
				end
			end
		end
		
		exports.messages:createMessage( "Username and/or password is incorrect.", "login" )
		guiSetEnabled( accounts_login_view.window, false )
	end
	
	addEventHandler( "onClientGUIClick", accounts_login_view.button.login, processLogin, false )
	
	addEventHandler( "onClientKey", root,
		function( button, pressOrRelease )
			if ( button == "enter" ) and ( pressOrRelease ) and ( guiGetEnabled( accounts_login_view.button.login ) ) then
				processLogin( )
			end
		end
	)
	
	function processRegister( )
		local username = guiGetText( accounts_login_view.edit.username )
		local password = guiGetText( accounts_login_view.edit.password )
		
		if ( username:len( ) >= minimumUsernameLength ) then
			if ( username:len( ) <= maximumUsernameLength ) then
				if ( not password:find( username ) ) then
					if ( password:len( ) >= minimumPasswordLength ) then
						if ( password:len( ) <= maximumPasswordLength ) then
							exports.messages:createMessage( "Registering account, please wait.", "login", nil, true )
							guiSetEnabled( accounts_login_view.window, false )
							
							triggerServerEvent( "accounts:register", localPlayer, username, password )
						else
							exports.messages:createMessage( "Password must be at most " .. maximumPasswordLength .. " characters long.", "login" )
							guiSetEnabled( accounts_login_view.window, false )
						end
					else
						exports.messages:createMessage( "Password must be at least " .. minimumPasswordLength .. " characters long.", "login" )
						guiSetEnabled( accounts_login_view.window, false )
					end
				else
					exports.messages:createMessage( "Your password must not contain your username.", "login" )
					guiSetEnabled( accounts_login_view.window, false )
				end
			else
				exports.messages:createMessage( "Username must be at most " .. maximumUsernameLength .. " characters long.", "login" )
				guiSetEnabled( accounts_login_view.window, false )
			end
		else
			exports.messages:createMessage( "Username must be at least " .. minimumUsernameLength .. " characters long.", "login" )
			guiSetEnabled( accounts_login_view.window, false )
		end
	end
	
	addEventHandler( "onClientGUIClick", accounts_login_view.button.register, processRegister, false )
end

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		triggerServerEvent( "accounts:ready", localPlayer )
	end
)

addEvent( "accounts:showLogin", true )
addEventHandler( "accounts:showLogin", root,
	function( )
		showLoginMenu( )
	end
)

addEvent( "accounts:closeLogin", true )
addEventHandler( "accounts:closeLogin", root,
	function( )
		showLoginMenu( true )
		exports.messages:destroyMessage( "login" )
	end
)

addEvent( "accounts:onLogin", true )
addEventHandler( "accounts:onLogin", root,
	function( )
		triggerEvent( "accounts:closeLogin", localPlayer )
	end
)

addEvent( "accounts:onRegister", true )
addEventHandler( "accounts:onRegister", root,
	function( )
		showLoginMenu( )
		exports.messages:createMessage( "You have successfully registered an account! You may now log in with your account.", "login" )
		guiSetEnabled( accounts_login_view.window, false )
	end
)

addEvent( "accounts:enableGUI", true )
addEventHandler( "accounts:enableGUI", root,
	function( )
		if ( isElement( accounts_login_view.window ) ) then
			guiSetEnabled( accounts_login_view.window, true )
		end
	end
)