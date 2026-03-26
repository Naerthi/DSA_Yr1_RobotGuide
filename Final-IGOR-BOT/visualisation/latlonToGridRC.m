function [row, col] = latlonToGridRC(lat, lon, mapRef, occGrid)

latTop    = mapRef.latTop;
latBottom = mapRef.latBottom;
lonLeft   = mapRef.lonLeft;
lonRight  = mapRef.lonRight;

nRows = size(occGrid,1);
nCols = size(occGrid,2);

col = 1 + (lon - lonLeft) / (lonRight - lonLeft) * (nCols - 1);
row = 1 + (latTop - lat) / (latTop - latBottom) * (nRows - 1);

row = round(row);
col = round(col);

row = max(1, min(nRows, row));
col = max(1, min(nCols, col));

end