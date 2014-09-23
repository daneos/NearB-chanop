local function locator(lat,lon)
	local lengthofloc = 8 -- cuz i'm lazy (replace with length of table, you lazy ass)
	-- we explode our latitude and longitude
	latitude = tonumber(string.match(lat, '%d+%.%d+'))
	longitude = tonumber(string.match(lon, '%d+%.%d+'))
	-- then negate if necessary
	if string.find(lat, "S") then
		latitude = -latitude
	end
	if string.find(lon, "W") then
		longitude = -longitude
	end
	-- and we add some degrees to that
	longitude = longitude + 180
	latitude = latitude + 90
	-- to fix the coords
	-- Failsafe stuff
	if (longitude < 0 or longitude > 360 or latitude < 0 or latitude > 180) then
		return nil -- would be very greatful if you test it properly.
	else
		local qth = {}
		local k = ( 12 * (longitude-2*math.floor(longitude/2)))	-- I have to
		local l = ( 24 * (latitude - math.floor(latitude))) 		-- help myself a bit
 
		qth[1] = string.char( string.byte("A") + math.floor(longitude / 20) )
		qth[2] = string.char( string.byte("A") + math.floor(latitude / 10) )
		qth[3] = string.char( string.byte("0") + math.floor((longitude % 20)/2))
		qth[4] = string.char( string.byte("0") + math.floor((latitude % 10)/1))
		qth[5] = string.char( string.byte("A") + math.floor(k))
		qth[6] = string.char( string.byte("A") + math.floor(l))
		qth[7] = string.char( string.byte("0") + math.floor(10 * (k - math.floor(k) )))
		qth[8] = string.char( string.byte("0") + math.floor(10 * (l - math.floor(l) )))

		local loc = qth[1]
		for i=2,lengthofloc do 
			loc = (loc .. qth[i]) 
		end
		return loc
	end
end

return locator