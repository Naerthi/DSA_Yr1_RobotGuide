function routeRC = buildDetailedRoute(nodePath, nodes, mapRef, occGrid)

if isempty(nodePath)
    routeRC = [];
    return;
end

routeRC = [];

for i = 1:(length(nodePath)-1)
    n1 = nodePath(i);
    n2 = nodePath(i+1);

    lat1 = nodes.coords(n1,1);
    lon1 = nodes.coords(n1,2);
    lat2 = nodes.coords(n2,1);
    lon2 = nodes.coords(n2,2);

    [r1, c1] = latlonToGridRC(lat1, lon1, mapRef, occGrid);
    [r2, c2] = latlonToGridRC(lat2, lon2, mapRef, occGrid);

    % If snapped point lands in occupied cell, move to nearest free one
    [r1, c1] = snapToNearestFree(occGrid, r1, c1);
    [r2, c2] = snapToNearestFree(occGrid, r2, c2);

    segRC = astarGridPath(occGrid, [r1 c1], [r2 c2]);

    if i > 1
        segRC = segRC(2:end,:);  % avoid duplicate join point
    end

    routeRC = [routeRC; segRC]; 
end

end