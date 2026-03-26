function [lat, lon] = gridRCToLatlon(row, col, nodes, occGrid)

allLat = nodes.coords(:,1);
allLon = nodes.coords(:,2);

latMin = min(allLat);
latMax = max(allLat);
lonMin = min(allLon);
lonMax = max(allLon);

nRows = size(occGrid,1);
nCols = size(occGrid,2);

lon = lonMin + (col - 1) / max(nCols - 1, 1) * (lonMax - lonMin);
lat = latMax - (row - 1) / max(nRows - 1, 1) * (latMax - latMin);

end