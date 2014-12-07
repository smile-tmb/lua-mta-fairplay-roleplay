bikes = { [ 581 ] = true, [ 509 ] = true, [ 481 ] = true, [ 462 ] = true, [ 521 ] = true, [ 463 ] = true, [ 510 ] = true, [ 522 ] = true, [ 461 ] = true, [ 448 ] = true, [ 468 ] = true, [ 586 ] = true, [ 536 ] = true, [ 575 ] = true, [ 567 ] = true, [ 480 ] = true, [ 555 ] = true }
windowless = { [ 568 ] = true, [ 601 ] = true, [ 424 ] = true, [ 457 ] = true, [ 480 ] = true, [ 485 ] = true, [ 486 ] = true, [ 528 ] = true, [ 530 ] = true, [ 531 ] = true, [ 532 ] = true, [ 571 ] = true, [ 572 ] = true }
roofless = { [ 568 ] = true, [ 500 ] = true, [ 439 ] = true, [ 424 ] = true, [ 457 ] = true, [ 480 ] = true, [ 485 ] = true, [ 486 ] = true, [ 530 ] = true, [ 531 ] = true, [ 533 ] = true, [ 536 ] = true, [ 555 ] = true, [ 571 ] = true, [ 572 ] = true, [ 575 ] = true }

function getBikeModels( )
	return bikes
end

function getWindowlessModels( )
	return windowless
end

function getRooflessModels( )
	return roofless
end

function isVehicleWindowsDown( vehicle )
	return getElementData( vehicle, "vehicle:windows" ) or false
end