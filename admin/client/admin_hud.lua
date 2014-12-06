local screenWidth, screenHeight = guiGetScreenSize( )

local showHUD = false
local adminCount = 0
local ticketCount = 0
local levelName = ""
local adminMode = true
local hudShowing = false

function updateAdminHUD( )
	showHUD = exports.common:isPlayerServerTrialAdmin( localPlayer )
	
	if ( showHUD ) then
		adminCount = #exports.common:getPriorityPlayers( )
		ticketCount = #getTickets( )
		levelName = exports.common:getLevelName( exports.common:getPlayerLevel( localPlayer ) )
		adminMode = exports.common:isOnDuty( localPlayer )
	end
end

function showAdminHUD( )
	updateAdminHUD( )
	
	if ( showHUD ) and ( not hudShowing ) then
		addEventHandler( "onClientRender", root, adminHUD )
		hudShowing = true
	end
end
addEvent( "admin:showHUD", true )
addEventHandler( "admin:showHUD", root, showAdminHUD )
addEventHandler( "onClientResourceStart", resourceRoot, showAdminHUD )

function hideAdminHUD( )
	if ( hudShowing ) then
		removeEventHandler( "onClientRender", root, adminHUD )
		hudShowing = false
	end
end
addEvent( "admin:hideHUD", true )
addEventHandler( "admin:hideHUD", root, hideAdminHUD )

addEvent( "admin:updateHUD", true )
addEventHandler( "admin:updateHUD", root,
	function( )
		updateAdminHUD( )
	end
)

function adminHUD( )
	if ( not showHUD ) or ( not hudShowing ) then
		return
	end
	
	local screenHeight = screenHeight
	
	-- admin mode hud
	if ( adminMode ) then
		local boxPaddingX = 5
		local boxPaddingY = 3
		
		local text = "admin duty mode | immortal"
		local textX, textY = 0, 0
		local textWidth = dxGetTextWidth( text )
		local textHeight = dxGetFontHeight( )
		
		local boxX, boxY = 0, 0
		local boxWidth = textWidth + ( boxPaddingX * 2 )
		local boxHeight = textHeight + ( boxPaddingY * 2 )
		
		screenHeight = screenHeight - ( boxHeight + boxPaddingY )
		
		textX = screenWidth - ( textWidth + boxPaddingX )
		textY = screenHeight - ( textHeight + boxPaddingY )
		
		boxX = screenWidth - ( textWidth + ( boxPaddingX * 2 ) )
		boxY = screenHeight - ( textHeight + ( boxPaddingY * 2 ) )
		
		dxDrawRectangle( boxX, boxY, boxWidth, boxHeight, tocolor( 0, 0, 0, 175 ) )
		dxDrawText( text, textX, textY, textX + textWidth, textY + textHeight, tocolor( 255, 255, 255, 200 ) )
	end
	
	-- admin level hud
	local boxPaddingX = 5
	local boxPaddingY = 3
	
	local text = "level | " .. levelName
	local textX, textY = 0, 0
	local textWidth = dxGetTextWidth( text )
	local textHeight = dxGetFontHeight( )
	
	local boxX, boxY = 0, 0
	local boxWidth = textWidth + ( boxPaddingX * 2 )
	local boxHeight = textHeight + ( boxPaddingY * 2 )
	
	local screenHeight = screenHeight - ( boxHeight + boxPaddingY )
	
	textX = screenWidth - ( textWidth + boxPaddingX )
	textY = screenHeight - ( textHeight + boxPaddingY )
	
	boxX = screenWidth - ( textWidth + ( boxPaddingX * 2 ) )
	boxY = screenHeight - ( textHeight + ( boxPaddingY * 2 ) )
	
	dxDrawRectangle( boxX, boxY, boxWidth, boxHeight, tocolor( 0, 0, 0, 175 ) )
	dxDrawText( text, textX, textY, textX + textWidth, textY + textHeight, tocolor( 255, 255, 255, 200 ) )
	
	-- tickets hud
	local boxPaddingX = 5
	local boxPaddingY = 3
	
	local text = ticketCount .. " open ticket" .. ( ticketCount == 1 and "" or "s" )
	local textX, textY = 0, 0
	local textWidth = dxGetTextWidth( text )
	local textHeight = dxGetFontHeight( )
	
	local boxX, boxY = 0, 0
	local boxWidth = textWidth + ( boxPaddingX * 2 )
	local boxHeight = textHeight + ( boxPaddingY * 2 )
	
	local screenHeight = screenHeight - ( boxHeight + boxPaddingY )
	
	textX = screenWidth - ( textWidth + boxPaddingX )
	textY = screenHeight - ( textHeight + boxPaddingY )
	
	boxX = screenWidth - ( textWidth + ( boxPaddingX * 2 ) )
	boxY = screenHeight - ( textHeight + ( boxPaddingY * 2 ) )
	
	dxDrawRectangle( boxX, boxY, boxWidth, boxHeight, tocolor( 0, 0, 0, 175 ) )
	dxDrawText( text, textX, textY, textX + textWidth, textY + textHeight, tocolor( 255, 255, 255, 200 ) )
	
	-- admin number hud
	local boxPaddingX = 5
	local boxPaddingY = 3
	
	local text = adminCount .. " admin" .. ( adminCount == 1 and "" or "s" ) .. " online"
	local textX, textY = 0, 0
	local textWidth = dxGetTextWidth( text )
	local textHeight = dxGetFontHeight( )
	
	local boxX, boxY = 0, 0
	local boxWidth = textWidth + ( boxPaddingX * 2 )
	local boxHeight = textHeight + ( boxPaddingY * 2 )
	
	local screenHeight = screenHeight - ( boxHeight + boxPaddingY )
	
	textX = screenWidth - ( textWidth + boxPaddingX )
	textY = screenHeight - ( textHeight + boxPaddingY )
	
	boxX = screenWidth - ( textWidth + ( boxPaddingX * 2 ) )
	boxY = screenHeight - ( textHeight + ( boxPaddingY * 2 ) )
	
	dxDrawRectangle( boxX, boxY, boxWidth, boxHeight, tocolor( 0, 0, 0, 175 ) )
	dxDrawText( text, textX, textY, textX + textWidth, textY + textHeight, tocolor( 255, 255, 255, 200 ) )
end