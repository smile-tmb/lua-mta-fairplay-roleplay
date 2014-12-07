addEvent( "accounts:onTutorialComplete", true )
addEventHandler( "accounts:onTutorialComplete", root,
	function( )
		if ( source ~= client ) then
			return
		end
		
		setCameraTarget( client, client )
		
		exports.database:execute( "UPDATE `accounts` SET `tutorial` = '1', `tutorial_date` = NOW() WHERE `id` = ?", exports.common:getCharacterID( client ) )
	end
)