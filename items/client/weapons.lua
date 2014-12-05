addEventHandler( "onClientPlayerWeaponFire", root,
	function( weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement, startX, startY, startZ )
		if ( exports.common:isPlayerPlaying( localPlayer ) ) and ( not exports.admin:isServerInMaintenance( ) ) and ( not exports.admin:isServerOverloaded( ) ) then
			triggerServerEvent( "weapons:fire", localPlayer, weapon )
			setElementData( localPlayer, "temp:need_synchronization", true, false )
		end
	end
)