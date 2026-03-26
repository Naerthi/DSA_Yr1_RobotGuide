function d = latlonDistanceMeters(lat1, lon1, lat2, lon2)

% Convert latitude/longitude differences into meters
meanLat = (lat1 + lat2) / 2;

dy = (lat2 - lat1) * 111320;
dx = (lon2 - lon1) * 111320 * cosd(meanLat);

d = sqrt(dx^2 + dy^2);

end

