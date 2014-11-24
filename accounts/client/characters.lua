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

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		character_selection.window = guiCreateWindow( ( screenWidth - 536 ) / 2, ( screenHeight - 346 ) / 2, 536, 346, "Character selection", false )
		guiWindowSetSizable( character_selection.window, false )
		
		character_selection.tabpanel = guiCreateTabPanel( 11, 29, 515, 307, false, character_selection.window )
		
		-- Select character
		character_selection.tab.select = guiCreateTab( "Select character", character_selection.tabpanel )
		
		character_selection.characters = guiCreateGridList( 10, 12, 495, 216, false, character_selection.tab.select )
		guiGridListAddColumn( character_selection.characters, "Name", 0.5 )
		guiGridListAddColumn( character_selection.characters, "Last played", 0.45 )
		
		character_selection.button.play = guiCreateButton( 10, 238, 495, 35, "Play character", false, character_selection.tab.select )
		
		addEventHandler( "onClientGUIClick", character_selection.button.play,
			function( )
				
			end, false
		)
		
		-- Create character
		local month, year = math.random( 1, 12 ), math.random( 1900, 2004 )
        local daysInMonth = exports.common:getDaysInMonth( month, year )
        local day = math.random( 1, daysInMonth )
		
		character_selection.tab.create = guiCreateTab( "Create character", character_selection.tabpanel )
		
		character_selection.label[ 1 ] = guiCreateLabel( 10, 10, 210, 15, "Character name", false, character_selection.tab.create )
		guiSetFont( character_selection.label[ 1 ], "default-bold-small" )
		
		character_selection.edit.character_name = guiCreateEdit( 10, 35, 210, 28, "", false, character_selection.tab.create )
		
		character_selection.label[ 2 ] = guiCreateLabel( 10, 73, 210, 15, "Date of birth", false, character_selection.tab.create )
		guiSetFont( character_selection.label[ 2 ], "default-bold-small" )
		
		character_selection.combobox.day = guiCreateComboBox( 11, 98, 53, 24, "Day...", false, character_selection.tab.create )
		
		for i = 1, daysInMonth do
			guiComboBoxAddItem( character_selection.combobox.day, i )
			
			local width = guiGetSize( character_selection.combobox.day, false )
			
			guiSetSize( character_selection.combobox.day, width, i * 20 + 20, false )
		end
		
		guiComboBoxSetSelected( character_selection.combobox.day, day - 1 )
		
		character_selection.combobox.month = guiCreateComboBox( 74, 98, 53, 24, "Month...", false, character_selection.tab.create )
		
		for i = 1, 12 do
			guiComboBoxAddItem( character_selection.combobox.month, i )
			
			local width = guiGetSize( character_selection.combobox.month, false )
			
			guiSetSize( character_selection.combobox.month, width, i * 20 + 20, false )
		end
		
		guiComboBoxSetSelected( character_selection.combobox.month, month - 1 )
		
		character_selection.combobox.year = guiCreateComboBox( 137, 98, 83, 24, "Year...", false, character_selection.tab.create )
		
		for i = 1900, 2004 do
			guiComboBoxAddItem( character_selection.combobox.year, i )
			
			local width = guiGetSize( character_selection.combobox.year, false )
			
			guiSetSize( character_selection.combobox.year, width, i * 20 + 20, false )
		end
		
		guiComboBoxSetSelected( character_selection.combobox.year, year - 1901 )
		
		character_selection.label[ 3 ] = guiCreateLabel( 10, 132, 117, 15, "Gender", false, character_selection.tab.create )
		guiSetFont( character_selection.label[ 3 ], "default-bold-small" )
		
		character_selection.combobox.gender = guiCreateComboBox( 10, 157, 117, 24, "Gender...", false, character_selection.tab.create )
		
		guiComboBoxAddItem( character_selection.combobox.gender, "Male" )
		guiComboBoxAddItem( character_selection.combobox.gender, "Female" )
	
		local width = guiGetSize( character_selection.combobox.gender, false )
		
		guiSetSize( character_selection.combobox.gender, width, 2 * 20 + 20, false )
		
		guiComboBoxSetSelected( character_selection.combobox.gender, math.random( 0, 1 ) )
		
		character_selection.label[ 4 ] = guiCreateLabel( 10, 191, 117, 15, "Skin color", false, character_selection.tab.create )
		guiSetFont( character_selection.label[ 4 ], "default-bold-small" )
		
		character_selection.combobox.skin_color = guiCreateComboBox( 10, 216, 117, 24, "Skin color...", false, character_selection.tab.create )
		
		guiComboBoxAddItem( character_selection.combobox.skin_color, "White" )
		guiComboBoxAddItem( character_selection.combobox.skin_color, "Black" )
		guiComboBoxAddItem( character_selection.combobox.skin_color, "Asian" )
	
		local width = guiGetSize( character_selection.combobox.skin_color, false )
		
		guiSetSize( character_selection.combobox.skin_color, width, 3 * 20 + 20, false )
		
		guiComboBoxSetSelected( character_selection.combobox.skin_color, math.random( 0, 2 ) )
		
		character_selection.skin = guiCreateStaticImage( 137, 157, 83, 83, "images/models/" .. selectedSkin .. ".png", false, character_selection.tab.create )
		
		character_selection.button.skin_previous = guiCreateButton( 147, 250, 26, 23, "<", false, character_selection.tab.create )
		character_selection.button.skin_next = guiCreateButton( 184, 250, 26, 23, ">", false, character_selection.tab.create )
		
		character_selection.label[ 7 ] = guiCreateLabel( 137, 132, 83, 15, "Skin model", false, character_selection.tab.create )
		guiSetFont( character_selection.label[ 7 ], "default-bold-small" )	
		
		character_selection.label[ 5 ] = guiCreateLabel( 260, 10, 210, 15, "Origin", false, character_selection.tab.create )
		guiSetFont( character_selection.label[ 5 ], "default-bold-small" )
		
		character_selection.edit.origin = guiCreateEdit( 260, 35, 210, 28, "", false, character_selection.tab.create )
		
		character_selection.label[ 6 ] = guiCreateLabel( 260, 73, 210, 15, "Look", false, character_selection.tab.create )
		guiSetFont( character_selection.label[ 6 ], "default-bold-small" )
		
		character_selection.memo.look = guiCreateMemo( 260, 98, 210, 82, "", false, character_selection.tab.create )
		
		character_selection.button.create = guiCreateButton( 260, 206, 210, 33, "Create character", false, character_selection.tab.create )
		
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
				
				if ( found ) then
					guiStaticImageLoadImage( character_selection.skin, "images/models/" .. selectedSkin .. ".png" )
				end
			end, false
		)
		
		addEventHandler( "onClientGUIClick", character_selection.button.create,
			function( )
				
			end, false
		)
	end
)