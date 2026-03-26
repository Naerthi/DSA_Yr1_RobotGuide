function items = list_all_key_distances(list, refLat, refLon)
%LIST_ALL_KEY_DISTANCES Return key points sorted by distance from a reference.

current = list.head;
items = repmat(struct('name', "", 'lat', 0, 'lon', 0, 'distance', inf), list.length, 1);
idx = 0;
while current ~= 0
    idx = idx + 1;
    items(idx).name = list.nodes(current).name;
    items(idx).lat = list.nodes(current).lat;
    items(idx).lon = list.nodes(current).lon;
    items(idx).distance = latlonDistanceMeters(refLat, refLon, list.nodes(current).lat, list.nodes(current).lon);
    current = list.nodes(current).next;
end

[~, order] = sort([items.distance]);
items = items(order);
end
