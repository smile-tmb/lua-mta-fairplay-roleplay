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

local screenWidth, screenHeight = guiGetScreenSize( )

local viewEnabled = false
local viewIndex = tonumber( getElementData( localPlayer, "temp:tutorial_step" ) ) or 1
local viewTimer
local viewPoints = {
	{
		posX = 1701.24,
		posY = -1899.09,
		posZ = 109.29,
		aimX = 1609.51,
		aimY = -1751.45,
		aimZ = 109.29,
		title = "Welcome to Los Santos",
		body = [[You have just arrived to Los Santos. The city of the rich and the city of the poor - Vinewood stars and gangbangers through out the city. Take a peek behind the Vinewood hills at the country side or live among the famous stars at Richman district. It's all your choice. This is a tutorial by the way. This lasts for about three minutes so learn as much as you can!]],
		width = 510,
		height = 132,
		speed = 0,
		wait = 17300,
		fov = 84
	},
	{
		posX = 1497,
		posY = -1675.54,
		posZ = 48.35,
		aimX = 1553.09,
		aimY = -1675.59,
		aimZ = 16.19,
		title = "San Andreas State Police",
		body = [[If you'd like to help the state maintain its peace and justice, join the peacekeepers, also known as the San Andreas State Police. State Police is a state-wide police force able to respond to any duty call within San Andreas.]],
		width = 500,
		height = 115,
		speed = 4000,
		wait = 17300
	},
	{
		posX = 1993.79,
		posY = -1464.75,
		posZ = 39.35,
		aimX = 2029.19,
		aimY = -1415.47,
		aimZ = 16.99,
		title = "San Andreas Medical and Fire Rescue",
		body = [[If you feel like rescuing poor people, feel free to join the hardworking fire fighters and emergency medical technicians at the San Andreas Medical and Fire Rescue Department. Like in State Police, the rescue department is able to respond to calls within San Andreas.]],
		width = 500,
		height = 115,
		speed = 4000,
		wait = 17300,
		fov = 80
	},
	{
		posX = 2283.69,
		posY = -1658.99,
		posZ = 14.97,
		aimX = 2382.98,
		aimY = -1658.9,
		aimZ = 14.05,
		title = "Gangs",
		body = [[.. or if you feel like becoming part of the illegal side of the server, you can join a gang or make your own! Of course, we're not limited to just gangs in the hoods, but mafias, triads, you name it.]],
		width = 500,
		height = 105,
		speed = 4000,
		wait = 17300,
		fov = 85
	},
	{
		posX = 1923.47,
		posY = -1418.15,
		posZ = 49.25,
		aimX = 1865.6,
		aimY = -1369.74,
		aimZ = 61.83,
		title = "Businesses",
		body = [[You are also able to create and join businesses. Some examples for businesses are for example the Los Santos News Office, or a local high-class bakery in Rodeo. You can become anything you want in Los Santos, to make it simple.]],
		width = 500,
		height = 115,
		speed = 4000,
		wait = 17300,
		fov = 100
	},
	{
		posX = 1332.18,
		posY = -1334.31,
		posZ = 62.95,
		aimX = 1398.71,
		aimY = -1311.77,
		aimZ = 71,
		title = "What's new?",
		body = [[Totally scripted from a scratch, given a look of our own to give it a finishing, truly amazing touch. Design looks great and works out well with nearly any resolution. Giving you the exclusive feeling of real roleplay and close to real life economy, it will be a great chance to improve your skills and experience something greatly new and fancy. Tens of thousands lines of code piling up and more to come.]],
		width = 520,
		height = 145,
		speed = 4000,
		wait = 17300,
		fov = 100
	},
	{
		posX = 1444.66,
		posY = -1504.27,
		posZ = 13.38,
		aimX = 1434.21,
		aimY = -1491.87,
		aimZ = 24.15,
		title = "Downtown",
		body = [[After this tutorial you'll arrive at Unity Station, just next to the city center, also known as Pershing Square, surrounded with the court house, police station, city hall and a few good hotels to stay and have a nap at. Here is a view of one of the cheapest hotels near Pershing Square.]],
		width = 500,
		height = 115,
		speed = 4000,
		wait = 17300,
		fov = 110,
		roll = 5
	},
	{
		posX = 1394.39,
		posY = -1649.14,
		posZ = 53.71,
		aimX = 1433.28,
		aimY = -1707.95,
		aimZ = 66.22,
		title = "Factions",
		body = [[How about the ability to create your very own company? Sure - fill up a form at City Hall and the employees will process it through for you. A wait of one day gives you access to all features of the system if accepted. Even though details about your company are needed, it will do everything for you so you can just sit back and relax! You are able to hire people to work for you and they'll be payed their wage for their work hours.]],
		width = 505,
		height = 145,
		speed = 5000,
		wait = 17300
	},
	{
		posX = 907.45,
		posY = -1772.51,
		posZ = 30.48,
		aimX = 932.87,
		aimY = -1743.92,
		aimZ = 17.46,
		title = "Vehicles",
		body = [[Giving you a realistic touch of driving and making it a bit more difficult ensures that driving will never again be unbalanced and unrealistic. Access vehicles with keys or hotwire and steal them if you have the right tools and skills! Car running low on gasoline? Stop at the next gas station to fill up the gas tank and perhaps have a tasty cup of coffee inside in the store.]],
		width = 500,
		height = 145,
		speed = 5000,
		wait = 17300
	},
	{
		posX = 1314.81,
		posY = -684.14,
		posZ = 117.77,
		aimX = 1328.85,
		aimY = -661.34,
		aimZ = 109.13,
		title = "Properties",
		body = [[Ability to purchase your own properties and manage them has always been amazing and fun. Having a place to live at is great. If you have enough money, why not buy a big house with a lot of space in the back, including a big cosy pool! Have a swim or dive, either way it's always refreshing and cooling you up on a hot sunny summer day.]],
		width = 500,
		height = 135,
		speed = 5000,
		wait = 17300
	},
	{
		posX = 998.84,
		posY = -385.87,
		posZ = 98.79,
		aimX = 1041.52,
		aimY = -344.64,
		aimZ = 81.55,
		title = "Weather and Seasons",
		body = [[Spring, summer, fall, winter. All within the server and fully functional. Making streets and areas snowy when snowing, and making them hard to drive on, while during summer there is most of the time sunny and bright. These are taken into account in the script. Weather also changes dynamically and realistically.]],
		width = 500,
		height = 130,
		speed = 5000,
		wait = 17300
	},
	{
		posX = 850.98,
		posY = -1607.62,
		posZ = 13.34,
		aimX = 841.86,
		aimY = -1597.53,
		aimZ = 14.54,
		title = "Education",
		body = [[Experience new things and educate yourself. Improve your skills and learn about stuff. These are also taken into account and are worth mentioning as they always change your character's mood and how the character works and reacts. You can learn new languages and improve your skills on hotwiring a car, for example.]],
		width = 500,
		height = 130,
		speed = 5000,
		wait = 17300
	},
	{
		posX = 1711.12,
		posY = -1912,
		posZ = 92.34,
		aimX = 1713.12,
		aimY = -1912,
		aimZ = 13.56,
		title = "Are you ready to begin?",
		body = [[This is the end of the tutorial scene. You are now put in controls of your role-play character. Spend time in creating the most unique and awesome experience for your character. If you ever need assistance with gameplay or have a thing to report to us, please use the report tool by pressing F2 or typing /report. Without any further, do enjoy and have fun!]],
		width = 500,
		height = 130,
		speed = 6000,
		wait = 17300
	},
}

local function render( )
	if ( not viewEnabled ) then
		return
	end
	
	local view = viewPoints[ viewIndex - 1 ]
	
	if ( not view ) then
		return
	end
	
	local boxX, boxY = 45, screenHeight - ( view.height + 55 )
	local boxPadding = 15
	
	local titleX, titleY = boxX + boxPadding, boxY + boxPadding
	local titleWidth = dxGetTextWidth( view.title, 1.5, "clear" )
	local titleHeight = dxGetFontHeight( 1.5, "clear" )
	
	local bodyMarginTop = 7
	local bodyX, bodyY = titleX, titleY + titleHeight + bodyMarginTop
	local bodyWidth = dxGetTextWidth( view.body, 1.0, "clear" )
	local bodyHeight = dxGetFontHeight( 1.0, "clear" )
	
	dxDrawRectangle( boxX, boxY, view.width, view.height, tocolor( 0, 0, 0, 0.85 * 255 ), true )
	dxDrawText( view.title, titleX, titleY, titleX + titleWidth, titleY + titleHeight, tocolor( 255, 255, 255, 0.875 * 255 ), 1.5, "clear", "left", "top", true, false, true, false, false )
	dxDrawText( view.body, bodyX, bodyY, bodyX + view.width - ( boxPadding * 2 ), bodyY + view.height - ( boxPadding * 2 ), tocolor( 255, 255, 255, 0.875 * 255 ), 1.0, "clear", "left", "top", false, true, true, false, false )
end

function moveToNextTutorialScene( )
	local view = viewPoints[ viewIndex ]
	
	if ( not view ) then
		hideTutorial( )
		
		viewIndex = 1
		
		setElementData( localPlayer, "temp:in_tutorial", false, true )
		setElementData( localPlayer, "temp:tutorial_step", false )
		setElementFrozen( localPlayer, false )
		
		toggleAllControls( true, true, false )
		
		triggerServerEvent( "accounts:onTutorialComplete", localPlayer )
		
		return
	end
	
	local lastViewIndex = viewIndex - 1 > 0 and viewIndex - 1 or #viewPoints
	local lastView = viewPoints[ lastViewIndex ]
	
	if ( view.speed >= 50 ) then
		setCameraMatrix( lastView.posX, lastView.posY, lastView.posZ, lastView.aimX, lastView.aimY, lastView.aimZ, view.roll or 0, view.fov or 70 )
		exports.common:smoothMoveCamera( lastView.posX, lastView.posY, lastView.posZ, lastView.aimX, lastView.aimY, lastView.aimZ, view.posX, view.posY, view.posZ, view.aimX, view.aimY, view.aimZ, view.speed, view.easing or nil, view.roll or nil, view.fov or nil )
	else
		setCameraMatrix( view.posX, view.posY, view.posZ, view.aimX, view.aimY, view.aimZ, view.roll or 0, view.fov or 70 )
	end
	
	local timerWait = view.speed + view.wait < 50 and 50 or view.speed + view.wait
	
	viewTimer = setTimer( moveToNextTutorialScene, timerWait, 1 )
	
	setElementData( localPlayer, "temp:tutorial_step", viewIndex, false )
	
	--if ( viewPoints[ viewIndex + 1 ] ) then
		viewIndex = viewIndex + 1
	--end
end

function showTutorial( )
	if ( not viewEnabled ) then
		hideTutorial( )
		moveToNextTutorialScene( )
		
		viewEnabled = true
		
		setElementData( localPlayer, "temp:in_tutorial", true, true )
		setElementFrozen( localPlayer, true )
		
		toggleAllControls( false, true, false )
		
		addEventHandler( "onClientRender", root, render )
	end
end
addEvent( "accounts:showTutorial", true )
addEventHandler( "accounts:showTutorial", root, showTutorial )
--addEventHandler( "onClientResourceStart", resourceRoot, showTutorial )

function hideTutorial( )
	if ( viewEnabled ) then
		if ( isTimer( viewTimer ) ) then
			killTimer( viewTimer )
		end
		
		exports.common:stopSmoothMoveCamera( )
		
		viewEnabled = false
		
		removeEventHandler( "onClientRender", root, render )
	end
end
addEvent( "accounts:hideTutorial", true )
addEventHandler( "accounts:hideTutorial", root, hideTutorial )