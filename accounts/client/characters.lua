local screenWidth, screenHeight = guiGetScreenSize( )
local character_selection = {
	tab = { },
	edit = { },
	label = { },
	button = { },
	combobox = { },
	memo = { }
}

do
	local function is_leap_year( year )
		return ( year % 4 == 0 ) and ( year % 100 ~= 0 or year % 400 == 0 )
	end
	
	function get_days_in_month( month, year )
		return month == 2 and is_leap_year( year ) and 29 or ( "\31\28\31\30\31\30\31\31\30\31\30\31" ):byte( month )
	end
end

local selectedSkin = 1

blackMales = { 7, 14, 15, 16, 17, 18, 20, 21, 22, 24, 25, 28, 35, 36, 50, 51, 66, 67, 78, 79, 80, 83, 84, 102, 103, 104, 105, 106, 107, 134, 136, 142, 143, 144, 156, 163, 166, 168, 176, 180, 182, 183, 185, 220, 221, 222, 249, 253, 260, 262 }
whiteMales = { 23, 26, 27, 29, 30, 32, 33, 34, 35, 36, 37, 38, 43, 44, 45, 46, 47, 48, 50, 51, 52, 53, 58, 59, 60, 61, 62, 68, 70, 72, 73, 78, 81, 82, 94, 95, 96, 97, 98, 99, 100, 101, 108, 109, 110, 111, 112, 113, 114, 115, 116, 120, 121, 122, 124, 125, 126, 127, 128, 132, 133, 135, 137, 146, 147, 153, 154, 155, 158, 159, 160, 161, 162, 164, 165, 170, 171, 173, 174, 175, 177, 179, 181, 184, 186, 187, 188, 189, 200, 202, 204, 206, 209, 212, 213, 217, 223, 230, 234, 235, 236, 240, 241, 242, 247, 248, 250, 252, 254, 255, 258, 259, 261, 264 }
asianMales = { 49, 57, 58, 59, 60, 117, 118, 120, 121, 122, 123, 170, 186, 187, 203, 210, 227, 228, 229 }
blackFemales = { 9, 10, 11, 12, 13, 40, 41, 63, 64, 69, 76, 91, 139, 148, 190, 195, 207, 215, 218, 219, 238, 243, 244, 245, 256 }
whiteFemales = { 12, 31, 38, 39, 40, 41, 53, 54, 55, 56, 64, 75, 77, 85, 86, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 140, 145, 150, 151, 152, 157, 172, 178, 192, 193, 194, 196, 197, 198, 199, 201, 205, 211, 214, 216, 224, 225, 226, 231, 232, 233, 237, 243, 246, 251, 257, 263 }
asianFemales = { 38, 53, 54, 55, 56, 88, 141, 169, 178, 224, 225, 226, 263 }

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
		local day, month, year = math.random( 1, get_days_in_month( getRealTime( ).month, getRealTime( ).year ) ), math.random( 1, 12 ), math.random( 1900, 2004 )
		
		character_selection.tab.create = guiCreateTab( "Create character", character_selection.tabpanel )
		
		character_selection.label[ 1 ] = guiCreateLabel( 10, 10, 210, 15, "Character name", false, character_selection.tab.create )
		guiSetFont( character_selection.label[ 1 ], "default-bold-small" )
		
		character_selection.edit.character_name = guiCreateEdit( 10, 35, 210, 28, "", false, character_selection.tab.create )
		
		character_selection.label[ 2 ] = guiCreateLabel( 10, 73, 210, 15, "Date of birth", false, character_selection.tab.create )
		guiSetFont( character_selection.label[ 2 ], "default-bold-small" )
		
		character_selection.combobox.day = guiCreateComboBox( 11, 98, 53, 24, "Day...", false, character_selection.tab.create )
		
		for i = 1, get_days_in_month( getRealTime( ).month, getRealTime( ).year ) do
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