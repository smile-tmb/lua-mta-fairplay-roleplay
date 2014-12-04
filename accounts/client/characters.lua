local screenWidth, screenHeight = guiGetScreenSize( )
local character_selection = {
	tab = { },
	edit = { },
	label = { },
	button = { },
	combobox = { },
	memo = { }
}

local selectedSkin = 1

function showCharacterSelection( forceClose )
	if ( isElement( character_selection.window ) ) then
		destroyElement( character_selection.window )
	end
	
	showCursor( false )
	guiSetInputEnabled( false )
	
	if ( forceClose ) then
		return
	end
	
	showCursor( true )
	guiSetInputEnabled( true )
	
	character_selection.window = guiCreateWindow( ( screenWidth - 536 ) / 2, ( screenHeight - 346 ) / 2, 536, 376, "Character Selection", false )
	guiWindowSetSizable( character_selection.window, false )
	
	character_selection.tabpanel = guiCreateTabPanel( 11, 29, 515, 337, false, character_selection.window )
	
	-- Select character
	character_selection.tab.select = guiCreateTab( "Select character", character_selection.tabpanel )
	
	character_selection.characters = guiCreateGridList( 10, 12, 495, 246, false, character_selection.tab.select )
	guiGridListAddColumn( character_selection.characters, "Name", 0.5 )
	guiGridListAddColumn( character_selection.characters, "Last played", 0.45 )
	
	character_selection.button.play = guiCreateButton( 10, 268, 495, 35, "Play character", false, character_selection.tab.select )
	
	function chooseCharacter( )
		local row, column = guiGridListGetSelectedItem( character_selection.characters )
		
		if ( row ~= -1 ) and ( column ~= -1 ) then
			local characterName = guiGridListGetItemText( character_selection.characters, row, column )
			
			triggerServerEvent( "characters:play", localPlayer, characterName )
		end
	end
	
	addEventHandler( "onClientGUIDoubleClick", character_selection.characters, chooseCharacter, false )
	addEventHandler( "onClientGUIClick", character_selection.button.play, chooseCharacter, false )
	
	-- Create character
	character_selection.tab.create = guiCreateTab( "Create character", character_selection.tabpanel )
	
	character_selection.label[ 1 ] = guiCreateLabel( 10, 10, 210, 15, "Character name", false, character_selection.tab.create )
	guiSetFont( character_selection.label[ 1 ], "default-bold-small" )
	
	character_selection.edit.character_name = guiCreateEdit( 10, 35, 210, 28, "", false, character_selection.tab.create )
	
	character_selection.label[ 2 ] = guiCreateLabel( 10, 73, 210, 15, "Date of birth", false, character_selection.tab.create )
	guiSetFont( character_selection.label[ 2 ], "default-bold-small" )
	
	character_selection.edit.birth_day = guiCreateEdit( 11, 98, 53, 24, "", false, character_selection.tab.create )
	character_selection.edit.birth_month = guiCreateEdit( 74, 98, 53, 24, "", false, character_selection.tab.create )
	character_selection.edit.birth_year = guiCreateEdit( 137, 98, 53, 24, "", false, character_selection.tab.create )
	
	character_selection.label[ 3 ] = guiCreateLabel( 10, 132, 117, 15, "Gender", false, character_selection.tab.create )
	guiSetFont( character_selection.label[ 3 ], "default-bold-small" )
	
	character_selection.combobox.gender = guiCreateComboBox( 10, 157, 117, 24, "Gender...", false, character_selection.tab.create )
	
	guiComboBoxAddItem( character_selection.combobox.gender, "Male" )
	guiComboBoxAddItem( character_selection.combobox.gender, "Female" )

	local width = guiGetSize( character_selection.combobox.gender, false )
	
	guiSetSize( character_selection.combobox.gender, width, 2 * 20 + 27, false )
	
	character_selection.label[ 4 ] = guiCreateLabel( 10, 191, 117, 15, "Skin color", false, character_selection.tab.create )
	guiSetFont( character_selection.label[ 4 ], "default-bold-small" )
	
	character_selection.combobox.skin_color = guiCreateComboBox( 10, 216, 117, 24, "Skin color...", false, character_selection.tab.create )
	
	guiComboBoxAddItem( character_selection.combobox.skin_color, "White" )
	guiComboBoxAddItem( character_selection.combobox.skin_color, "Black" )
	guiComboBoxAddItem( character_selection.combobox.skin_color, "Asian" )

	local width = guiGetSize( character_selection.combobox.skin_color, false )
	
	guiSetSize( character_selection.combobox.skin_color, width, 3 * 20 + 20, false )
	
	character_selection.skin = guiCreateStaticImage( 137, 157, 83, 83, "images/models/" .. selectedSkin .. ".png", false, character_selection.tab.create )
	
	character_selection.button.skin_previous = guiCreateButton( 147, 250, 26, 23, "<", false, character_selection.tab.create )
	character_selection.button.skin_next = guiCreateButton( 184, 250, 26, 23, ">", false, character_selection.tab.create )
	
	character_selection.label[ 7 ] = guiCreateLabel( 137, 132, 83, 15, "Skin (" .. selectedSkin .. ")", false, character_selection.tab.create )
	guiSetFont( character_selection.label[ 7 ], "default-bold-small" )	
	
	character_selection.label[ 5 ] = guiCreateLabel( 260, 10, 210, 15, "Origin", false, character_selection.tab.create )
	guiSetFont( character_selection.label[ 5 ], "default-bold-small" )
	
	character_selection.edit.origin = guiCreateEdit( 260, 35, 210, 28, "", false, character_selection.tab.create )
	
	character_selection.label[ 6 ] = guiCreateLabel( 260, 73, 210, 15, "Look", false, character_selection.tab.create )
	guiSetFont( character_selection.label[ 6 ], "default-bold-small" )
	
	character_selection.memo.look = guiCreateMemo( 260, 98, 210, 82, "", false, character_selection.tab.create )
	
	character_selection.button.create = guiCreateButton( 260, 206, 210, 33, "Create character", false, character_selection.tab.create )
	character_selection.button.randomize = guiCreateButton( 260, 250, 210, 33, "Randomize", false, character_selection.tab.create )
	
	addEventHandler( "onClientGUIClick", character_selection.button.skin_previous,
		function( )
			local found = false
			
			selectedSkin = selectedSkin - 1
			
			while ( not found ) do
				if ( selectedSkin < 1 ) then
					selectedSkin = getValidPedModels( )[ #getValidPedModels( ) ]
				end
				
				for _, skin in ipairs( getValidPedModels( ) ) do
					if ( skin == selectedSkin ) then
						found = true
					end
				end
				
				if ( not found ) then
					selectedSkin = selectedSkin - 1
				end
			end
			
			guiSetText( character_selection.label[ 7 ], "Skin (" .. selectedSkin .. ")" )
			
			if ( found ) then
				guiStaticImageLoadImage( character_selection.skin, "images/models/" .. selectedSkin .. ".png" )
			end
		end, false
	)
	
	addEventHandler( "onClientGUIClick", character_selection.button.skin_next,
		function( )
			local found = false
			
			selectedSkin = selectedSkin + 1
			
			while ( not found ) do
				if ( selectedSkin > getValidPedModels( )[ #getValidPedModels( ) ] ) then
					selectedSkin = 1
				end
				
				for _, skin in ipairs( getValidPedModels( ) ) do
					if ( skin == selectedSkin ) then
						found = true
					end
				end
				
				if ( not found ) then
					selectedSkin = selectedSkin + 1
				end
			end
			
			guiSetText( character_selection.label[ 7 ], "Skin (" .. selectedSkin .. ")" )
			
			if ( found ) then
				guiStaticImageLoadImage( character_selection.skin, "images/models/" .. selectedSkin .. ".png" )
			end
		end, false
	)
	
	addEventHandler( "onClientGUIClick", character_selection.button.create,
		function( )
			local birthYear = guiGetText( character_selection.edit.birth_year )
			local birthMonth = guiGetText( character_selection.edit.birth_month )
			local birthDay = guiGetText( character_selection.edit.birth_day )
			
			local characterName = guiGetText( character_selection.edit.character_name )
			local characterDateOfBirth = birthYear .. "-" .. birthMonth .. "-" .. birthDay
			local characterGender = guiComboBoxGetItemText( character_selection.combobox.gender, guiComboBoxGetSelected( character_selection.combobox.gender ) )
			local characterSkinColor = guiComboBoxGetItemText( character_selection.combobox.skin_color, guiComboBoxGetSelected( character_selection.combobox.skin_color ) )
			local characterOrigin = guiGetText( character_selection.edit.origin )
			local characterLook = guiGetText( character_selection.memo.look )
			
			characterName = characterName:gsub( "%c%d\!\?\=\)\(\\\/\"\#\&\%\[\]\{\}\*\^\~\:\;\>\<", "" ):gsub( "_", " " )
			guiSetText( character_selection.edit.character_name, characterName )
			
			function invalidDateOfBirth( )
				exports.messages:createMessage( "Entered date of birth is not valid.", "selection" )
				guiSetEnabled( character_selection.window, false )
			end
			
			if ( characterName:len( ) >= minimumNameLength ) then
				if ( characterName:len( ) <= maximumNameLength ) then
					if ( not birthDay:find( "%D" ) ) and ( not birthMonth:find( "%D" ) ) and ( not birthYear:find( "%D" ) ) then
						if ( tonumber( birthDay ) >= minimumBirthDay ) then
							if ( tonumber( birthDay ) <= maximumBirthDay ) then
								if ( tonumber( birthMonth ) >= minimumBirthMonth ) then
									if ( tonumber( birthMonth ) <= maximumBirthMonth ) then
										if ( tonumber( birthYear ) >= minimumBirthYear ) then
											if ( tonumber( birthYear ) <= maximumBirthYear ) then
												if ( characterOrigin:len( ) >= minimumOriginLength ) then
													if ( characterOrigin:len( ) <= maximumOriginLength ) then
														exports.messages:createMessage( "Creating character, please wait.", "selection", nil, true )
														guiSetEnabled( character_selection.window, false )
														
														triggerServerEvent( "characters:create", localPlayer, selectedSkin, characterName, characterDateOfBirth, characterGender, characterSkinColor, characterOrigin, characterLook )
													else
														exports.messages:createMessage( "Character origin must be at most " .. maximumOriginLength .. " characters long.", "selection" )
														guiSetEnabled( character_selection.window, false )
													end
												else
													exports.messages:createMessage( "Character origin must be at least " .. minimumOriginLength .. " characters long.", "selection" )
													guiSetEnabled( character_selection.window, false )
												end
											else
												invalidDateOfBirth( )
											end
										else
											invalidDateOfBirth( )
										end
									else
										invalidDateOfBirth( )
									end
								else
									invalidDateOfBirth( )
								end
							else
								invalidDateOfBirth( )
							end
						else
							invalidDateOfBirth( )
						end
					else
						invalidDateOfBirth( )
					end
				else
					exports.messages:createMessage( "Character name must be at most " .. maximumNameLength .. " characters long.", "selection" )
					guiSetEnabled( character_selection.window, false )
				end
			else
				exports.messages:createMessage( "Character name must be at least " .. minimumNameLength .. " characters long.", "selection" )
				guiSetEnabled( character_selection.window, false )
			end
		end, false
	)
	
	function randomizeValues( )
		local origins = { "New York City, New York USA", "Las Venturas, San Andreas USA", "San Fierro, San Andreas USA", "Los Santos, San Andreas USA", "Toronto, Canada", "Helsinki, Finland", "Amsterdam, The Netherlands", "Paris, France", "Cologne, Germany", "Stockholm, Sweden", "Sitka, Alaska USA", "Juneau, Alaska USA", "Wrangell, Alaska USA", "Anchorage, Alaska USA", "Jacksonville, Florida USA", "Anaconda, Montana USA", "Butte, Montana USA", "Oklahoma City, Oklahoma USA", "Houston, Texas USA", "Phoenix, Arizona USA", "Nashville, Tennessee USA", "San Antonio, Texas USA", "Suffolk, Virginia USA", "Buckeye, Arizona USA", "Indianapolis, Indiana USA", "Chesapeake, Virginia USA", "Dallas, Texas USA", "Fort Worth, Texas USA", "San Diego, California USA", "Memphis, Tennessee USA", "Kansas City, Missouri USA", "Augusta, Georgia USA", "Austin, Texas USA", "Charlotte, North Carolina USA", "Lexington, Kentucky USA", "El Paso, Texas USA", "Macon, Georgia USA", "Cusseta, Georgia USA", "Chicago, Illinois USA", "Tucson, Arizona USA", "Columbus, Ohio USA", "Columbus, Georgia USA", "Valdez, Alaska USA", "Preston, Georgia USA", "Huntsville, Alabama USA", "Boulder City, Nevada USA", "California City, California USA", "Tulsa, Oklahoma USA", "Goodyear, Arizona USA", "Albuquerque, New Mexico USA", "Scottsdale, Arizona USA", "London, United Kingdom", "Turku, Finland", "Moscow, Russia", "Saint Petersburg, Russia", "Sydney, Australia", "Melbourne, Australia", "Brisbane, Australia", "Belfast, Northern Ireland", "Hamburg, Germany", "Oslo, Norway", "Hilversum, The Netherlands", "Warsaw, Poland", "Madrid, Spain", "Mexico City, Mexico", "Philadelphia, Pennsylvania USA", "Phoenix, Arizona USA", "San Antonio, Texas USA", "Dallas, Texas USA", "San Jose, California USA", "Detroit, Michigan USA", "Seattle, Washington USA", "Denver, Colorado USA", "Washington, District of Columbia USA", "Boston, Massachusetts USA", "Baltimore, Maryland USA", "Louisville, Kentucky USA", "Portland, Oregon USA", "Milwaukee, Wisconsin USA", "Sacramento, California USA", "Kansas City, Missouri USA", "Mesa, Arizona USA", "Atlanta, Georgia USA", "Omaha, Nebraska USA", "Colorado Springs, Colorado USA", "Raleigh, North Carolina USA", "Miami, Florida USA", "Oakland, California USA", "Cleveland, Ohio USA", "Arlington, Texas USA", "New Orleans, Louisiana USA", "Bakersfield, California USA", "Tampa, Florida USA", "Honolulu, Hawai'i", "Aurora, Colorado USA", "Anaheim, California USA", "Santa Ana, California USA", "Saint Louis, Missouri USA", "Riverside, California USA", "Lexington, Kentucky USA", "Pittsburgh, Pennsylvania USA", "Stockton, California USA", "Buffalo, New York USA", "Saint Petersburg, Florida USA", "Davenport, Iowa USA", "Waterbury, Connecticut USA", "Elgin, Illinois USA", "Gresham, Oregon USA", "Billings, Montana USA", "Manchester, New Hampshire USA", "Wilmington, North Carolina USA", "Fargo, North Dakota", "Lansing, Michigan USA", "Provo, Utah USA", "Albany, New York USA", "Shanghai, China", "Tokyo, Japan", "Yerevan, Armenia", "Baku, Azerbaijan", "Manama, Bahrain", "Beijing, China", "Nicosia, Cyprus", "New Delhi, India", "Jakarta, Indonesia", "Tbilisi, Georgia", "Singapore, Republic of Singapore", "Bangkok, Thailand", "Ankara, Turkey", "Abu Dhabi, United Arab Emirates", "Tashkent, Uzbekistan", "Taipei, Taiwan", "Hong Kong, China" }
		local month, year = math.random( minimumBirthMonth, maximumBirthMonth ), math.random( minimumBirthYear + 40, maximumBirthYear )
		local daysInMonth = exports.common:getDaysInMonth( month, year )
		local day = math.random( minimumBirthDay, daysInMonth )
		
		guiSetText( character_selection.edit.birth_day, day )
		guiSetText( character_selection.edit.birth_month, month )
		guiSetText( character_selection.edit.birth_year, year )
		
		guiSetText( character_selection.edit.origin, origins[ math.random( #origins ) ] )
		
		local genderList = { "Male", "Female" }
		local skinColorList = { "White", "Black", "Asian" }
		
		local genderSelected = math.random( 1, 2 )
		local skinColorSelected = math.random( 1, 3 )
		
		guiComboBoxSetSelected( character_selection.combobox.gender, genderSelected - 1 )
		guiComboBoxSetSelected( character_selection.combobox.skin_color, skinColorSelected - 1 )
		
		local skins = exports.common:getValidPedModelsByGenderAndColor( genderList[ genderSelected ]:lower( ), skinColorList[ skinColorSelected ]:lower( ) )
		
		selectedSkin = skins[ math.random( #skins ) ]
		
		guiSetText( character_selection.label[ 7 ], "Skin (" .. selectedSkin .. ")" )
		guiStaticImageLoadImage( character_selection.skin, "images/models/" .. selectedSkin .. ".png" )
	end
	
	randomizeValues( )
	
	addEventHandler( "onClientGUIClick", character_selection.button.randomize, randomizeValues, false )
end

addEvent( "accounts:addCharacters", true )
addEventHandler( "accounts:addCharacters", root,
	function( characters )
		if ( isElement( character_selection.window ) ) then
			for _, character in ipairs( characters ) do
				local row = guiGridListAddRow( character_selection.characters )
				guiGridListSetItemText( character_selection.characters, row, 1, character.name:gsub( "_", " " ), false, false )
				guiGridListSetItemText( character_selection.characters, row, 2, character.last_played, false, false )
			end
		end
	end
)

function onLogin( )
	triggerEvent( "accounts:showCharacterSelection", localPlayer )
end
addEvent( "accounts:onLogin", true )
addEventHandler( "accounts:onLogin", root, onLogin )
addEvent( "accounts:onLogin.characters", true )
addEventHandler( "accounts:onLogin.characters", root, onLogin )

function onLogout( )
	triggerEvent( "characters:closeGUI", localPlayer )
end
addEvent( "accounts:onLogout", true )
addEventHandler( "accounts:onLogout", root, onLogout )
addEvent( "accounts:onLogout.characters", true )
addEventHandler( "accounts:onLogout.characters", root, onLogout )

addEvent( "accounts:showCharacterSelection", true )
addEventHandler( "accounts:showCharacterSelection", root,
	function( )
		showCharacterSelection( )
	end
)

addEvent( "characters:closeGUI", true )
addEventHandler( "characters:closeGUI", root,
	function( )
		exports.messages:destroyMessage( "selection" )
		showCharacterSelection( true )
	end
)

addEvent( "characters:onSpawn", true )
addEventHandler( "characters:onSpawn", root,
	function( )
		setPedCameraRotation( localPlayer, getPedRotation( localPlayer ) - 180 )
	end
)

addEvent( "characters:onCreate", true )
addEventHandler( "characters:onCreate", root,
	function( )
		triggerEvent( "characters:closeGUI", localPlayer )
	end
)

addEvent( "characters:enableGUI", true )
addEventHandler( "characters:enableGUI", root,
	function( )
		if ( isElement( character_selection.window ) ) then
			guiSetEnabled( character_selection.window, true )
		end
	end
)