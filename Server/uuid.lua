local mathRandom = math.random

function generateUUID()
	local sChar = "x"
	local sUUIDFormat ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub( sUUIDFormat, "[xy]", function( sChar )
        return string.format( "%x", ( sChar == "x" ) and mathRandom( 0, 0xf ) or mathRandom( 8, 0xb ) )
    end)
end
Package.Export("generateUUID", generateUUID)