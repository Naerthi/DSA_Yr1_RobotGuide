function h = plotNodePath(ax, nodes, mapRef, occGrid, nodePath, lineSpec, lineWidthVal)

if isempty(nodePath)
    h = [];
    return;
end

xy = zeros(length(nodePath), 2);

for i = 1:length(nodePath)
    idx = nodePath(i);

    [r, c] = latlonToGridRC(nodes.coords(idx,1), nodes.coords(idx,2), mapRef, occGrid);
    xy(i,:) = [c, r];
end

h = plot(ax, xy(:,1), xy(:,2), lineSpec, 'LineWidth', lineWidthVal);

end