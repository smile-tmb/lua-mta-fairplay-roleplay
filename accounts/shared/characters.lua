minimumNameLength, maximumNameLength = 5, 25
minimumBirthDay, maximumBirthDay = 1, 31
minimumBirthMonth, maximumBirthMonth = 1, 12
minimumBirthYear, maximumBirthYear = 1900, 2004
minimumOriginLength, maximumOriginLength = 2, 100

function getNameBounds( )
	return minimumNameLength, maximumNameLength
end

function getBirthDateBounds( )
	return { minimumBirthDay, maximumBirthDay }, { minimumBirthMonth, maximumBirthMonth }, { minimumBirthYear, maximumBirthYear }
end

function getOriginBounds( )
	return minimumOriginLength, maximumOriginLength
end