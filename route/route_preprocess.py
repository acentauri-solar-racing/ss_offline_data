from geopy.distance import distance

lat1 = temperature.lati[k, 0]
lon1 = temperature.long[k, 0]
lat2 = temperature.lati[k + 1, 0]
lon2 = temperature.long[k + 1, 0]

coord1 = (lat1, lon1)
coord2 = (lat2, lon2)

dist = distance(coord1, coord2).kilometers