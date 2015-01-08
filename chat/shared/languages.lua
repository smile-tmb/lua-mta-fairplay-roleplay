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

local maxLanguages = 3
local languages = { 
	{ "gb", "English" },
	{ "fi", "Finnish" },
	{ "ee", "Estonian" },
	{ "se", "Swedish" },
	{ "no", "Norwegian" },
	{ "dk", "Danish" },
	{ "nl", "Dutch" },
	{ "es", "Spanish" },
	{ "it", "Italian" },
	{ "ru", "Russian" },
	{ "de", "German" },
	{ "fr", "French" },
	{ "ja", "Japanese" },
	{ "cn", "Chinese" },
	{ "lt", "Lithuanian" },
	{ "sc", "Gaelic" },
	{ "il", "Hebrew" },
	{ "ro", "Romanian" },
	{ "pl", "Polish" },
	{ "pr", "Portuguese" },
	{ "al", "Albanian" },
	{ "af", "Arabic" },
	{ "gb", "Welsh" },
	{ "hu", "Hungarian" },
	{ "bo", "Bosnian" },
	{ "eu", "Greek" },
	{ "sb", "Serbian" },
	{ "ct", "Croatian" },
	{ "sl", "Slovak" },
	{ "af", "Persian" },
	{ "so", "Somalian" },
	{ "gy", "Georgian" },
	{ "eu", "Turkish" },
	{ "kr", "Korean" },
	{ "vn", "Vietnamese" },
	[ 1337 ] = { "cp", "MD5" }
}

function getLanguages(  )
	return languages
end

function getMaxLanguages( )
	return maxLanguages
end

function getLanguage( language )
	local language = tonumber( language )
	
	if ( language and languages[ language ] ) then
		return languages[ language ][ 1 ], languages[ language ][ 2 ]
	else
		return false
	end
end

function getLanguageFlag( language )
	local language = tonumber( language )
	
	if ( language and languages[ language ] ) then
		return languages[ language ][ 1 ]
	else
		return false
	end
end

function getLanguageName( language )
	local language = tonumber( language )
	
	if ( language and languages[ language ] ) then
		return languages[ language ][ 2 ]
	else
		return false
	end
end

function hasLanguage( player, language, slot, skill )
	if ( player ) and ( language ) then
		for index = ( slot or 1 ), ( slot or maxLanguages ) do
			local playerLanguage, playerSkill = getPlayerLanguage( player, index )
			
			if ( playerLanguage == language ) then
				if ( skill ) and ( skill ~= playerSkill ) then
					return false
				end
				
				return true, slot
			end
		end
	else
		return false
	end
end

function getFreeSlot( player )
	for index = 1, maxLanguages do
		if ( getPlayerLanguage( player, index ) == 0 ) then
			return index
		end
	end
	
	return false
end

function giveLanguage( player, language, slot, skill )
	if ( player ) and ( language ) then
		local hasLanguage = hasLanguage( player, language )
		
		if ( not hasLanguage ) then
			slot = slot or getFreeSlot( player )
			
			if ( slot ) then
				exports.security:modifyElementData( player, "character:language_" .. slot, language, true )
				exports.security:modifyElementData( player, "character:language_" .. slot .. "_skill", skill or 100, true )
				
				exports.database:execute( "UPDATE `languages` SET `language_" .. slot .. "` = ?, `skill_" .. slot .. "` = ? WHERE `character_id` = ?", language, skill, exports.common:getCharacterID( player ) )
				
				return true
			end
		end
	end
	
	return false
end

function takeLanguage( player, language )
	if ( player ) and ( language ) then
		local hasLanguage, playerSlot = hasLanguage( player, language )
		
		if ( hasLanguage ) then
			exports.security:modifyElementData( player, "character:language_" .. playerSlot, 0, true )
			exports.security:modifyElementData( player, "character:language_" .. playerSlot .. "skill", 0, true )
			
			exports.database:execute( "UPDATE `languages` SET `language_" .. playerSlot .. "` = '0', `skill_" .. playerSlot .. "` = '0' WHERE `character_id` = ?", exports.common:getCharacterID( player ) )
			
			return true
		else
			return false
		end
	else
		return false
	end
end

function increaseLanguageSkill( player, language )
	local hasLanguage, slot = hasLanguage( player, language )
	
	if ( hasLanguage ) then
		local _, skill = getPlayerLanguage( player, slot )
		
		if ( skill < 100 ) then
			local lucky = math.random( 1, math.max( math.ceil( skill / 3 ), 6 ) )
			
			if ( lucky == 1 ) then
				skill = skill + 1
				
				setElementData( player, "roleplay:languages." .. slot .. "skill", skill, true )
				
				exports.database:execute( "UPDATE `languages` SET `skill" .. slot .. "` = ? WHERE `character_id` = ?", skill, exports.common:getCharacterID( player ) )
				
				return true, skill
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

function getPlayerLanguage( player, slot )
	return tonumber( getElementData( player, "character:language_" .. slot ) ), tonumber( getElementData( player, "character:language_" .. slot .. "_skill" ) )
end

function getPlayerLanguages( player )
	local languages = { }
	
	for index = 1, maxLanguages do
		table.insert( languages, tonumber( getElementData( player, "character:language_" .. index ) ) )
	end
	
	return languages
end

function getPlayerLanguageSkill( player, language )
	local hasLanguage, slot = hasLanguage( player, language )
	
	if ( hasLanguage ) then
		local _, skill = getPlayerLanguage( player, slot )
		
		return skill
	else
		return 0
	end
end