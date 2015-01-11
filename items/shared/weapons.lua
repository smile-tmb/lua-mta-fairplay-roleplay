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

local weaponmodels = {
	[ 1 ] = 331, [ 2 ] = 333, [ 3 ] = 326, [ 4 ] = 335, [ 5 ] = 336, [ 6 ] = 337, [ 7 ] = 338, [ 8 ] = 339, [ 9 ] = 341,
	[ 15 ] = 326, [ 22 ] = 346, [ 23 ] = 347, [ 24 ] = 348, [ 25 ] = 349, [ 26 ] = 350, [ 27 ] = 351, [ 28 ] = 352,
	[ 29 ] = 353, [ 32 ] = 372, [ 30 ] = 355, [ 31 ] = 356, [ 33 ] = 357, [ 34 ] = 358, [ 35 ] = 359, [ 36 ] = 360,
	[ 37 ] = 361, [ 38 ] = 362, [ 16 ] = 342, [ 17 ] = 343, [ 18 ] = 344, [ 39 ] = 363, [ 41 ] = 365, [ 42 ] = 366,
	[ 43 ] = 367, [ 10 ] = 321, [ 11 ] = 322, [ 12 ] = 323, [ 14 ] = 325, [ 44 ] = 368, [ 45 ] = 369, [ 46 ] = 371,
	[ 40 ] = 364, [ 100 ] = 373
}

local weaponweights = {
	[ 22 ] = 1.14, [ 23 ] = 1.24, [ 24 ] = 2, [ 25 ] = 3.1, [ 26 ] = 2.1, [ 27 ] = 4.2, [ 28 ] = 3.6, [ 29 ] = 2.640, [ 30 ] = 4.3, [ 31 ] = 2.68, [ 32 ] = 3.6, [ 33 ] = 4.0, [ 34 ] = 4.3
}

local ammoweights = {
	[ 22 ] = 0.0224, [ 23 ] = 0.0224, [ 24 ] = 0.017, [ 25 ] = 0.037, [ 26 ] = 0.037, [ 27 ] = 0.037, [ 28 ] = 0.009, [ 29 ] = 0.012, [ 30 ] = 0.0165, [ 31 ] = 0.0112, [ 32 ] = 0.009, [ 33 ] = 0.0128, [ 34 ] = 0.027
}

function getWeaponModel( weaponID )
	return weaponmodels[ weaponID ] or itemlist[ 11 ].model
end

function getWeaponID( value )
	return exports.common:getSplitValues( value )[ 1 ]
end

function getWeaponName( value )
	local splitValues = exports.common:getSplitValues( value )
	
	return splitValues[ 2 ] or ( getWeaponNameFromID( splitValues[ 1 ] ) or itemlist[ 11 ].name )
end

function getWeaponDescription( value )
	return exports.common:getSplitValues( value )[ 3 ]
end

function getWeaponWeight( weaponID )
	return weaponweights[ weaponID ] or itemlist[ 11 ].weight
end

function getAmmoWeight( weaponID )
	return ammoweights[ weaponID ] or itemlist[ 12 ].weight
end