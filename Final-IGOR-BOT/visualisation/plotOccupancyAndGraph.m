function plotOccupancyAndGraph(ax, occGrid, nodes, mapRef, ~, waitingIdx, currentNode, startNode, goalNode, nearestWaitNode)

axes(ax);
cla(ax);
hold(ax, 'on');

imagesc(ax, occGrid);
axis(ax, 'image');

set(ax, 'XDir', 'normal');    % left to right is normal
set(ax, 'YDir', 'reverse');   % vertical flip

colormap(ax, [1 1 1; 0 0.6 0]);   % free = white, occupied = green
caxis(ax, [0 1]);

title(ax, 'IGOR GUIDE');

% % Plot all graph edges
% plotted = false(nodes.nTotal);
% 
% for i = 1:length(L_dij)
%     neighbors = L_dij{i}(:,1);
% 
%     [r1, c1] = latlonToGridRC(nodes.coords(i,1), nodes.coords(i,2), mapRef, occGrid);
% 
%     for k = 1:length(neighbors)
%         j = neighbors(k);
% 
%         if ~plotted(i,j)
%             [r2, c2] = latlonToGridRC(nodes.coords(j,1), nodes.coords(j,2), mapRef, occGrid);
%             plot(ax, [c1 c2], [r1 r2], 'Color', [0.5 0.5 0.5], 'LineWidth', 1.0, ...
%                 'DisplayName', 'Graph edge');
%             plotted(i,j) = true;
%             plotted(j,i) = true;
%         end
%     end
% end

% Plot nodes
for i = 1:nodes.nTotal
    [r, c] = latlonToGridRC(nodes.coords(i,1), nodes.coords(i,2), mapRef, occGrid);

    if i <= nodes.nKey
        plot(ax, c, r, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, ...
            'HandleVisibility', 'off');
    else
        plot(ax, c, r, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 5, ...
            'HandleVisibility', 'off');
    end

    text(ax, c+1, r, nodes.names{i}, 'FontSize', 8, 'Color', 'k');
end

% Dummy legend markers
plot(ax, nan, nan, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6, 'DisplayName', 'Key point');
plot(ax, nan, nan, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 5, 'DisplayName', 'Signal point');

% Waiting points
for idx = waitingIdx(:)'
    [r, c] = latlonToGridRC(nodes.coords(idx,1), nodes.coords(idx,2), mapRef, occGrid);
    plot(ax, c, r, 'gs', 'MarkerFaceColor', 'g', 'MarkerSize', 9, 'HandleVisibility', 'off');
end
plot(ax, nan, nan, 'gs', 'MarkerFaceColor', 'g', 'MarkerSize', 9, 'DisplayName', 'Waiting point');

% Current waiting point
[r, c] = latlonToGridRC(nodes.coords(currentNode,1), nodes.coords(currentNode,2), mapRef, occGrid);
plot(ax, c, r, 'ms', 'MarkerFaceColor', 'm', 'MarkerSize', 12, 'DisplayName', 'Initial waiting');

% Start point
[r, c] = latlonToGridRC(nodes.coords(startNode,1), nodes.coords(startNode,2), mapRef, occGrid);
plot(ax, c, r, 'co', 'MarkerFaceColor', 'c', 'MarkerSize', 10, 'DisplayName', 'Start');

% Goal point
[r, c] = latlonToGridRC(nodes.coords(goalNode,1), nodes.coords(goalNode,2), mapRef, occGrid);
plot(ax, c, r, 'yo', 'MarkerFaceColor', 'y', 'MarkerSize', 10, 'DisplayName', 'Goal');

% Return waiting point
[r, c] = latlonToGridRC(nodes.coords(nearestWaitNode,1), nodes.coords(nearestWaitNode,2), mapRef, occGrid);
plot(ax, c, r, 'kd', 'MarkerFaceColor', 'k', 'MarkerSize', 10, 'DisplayName', 'Return waiting');

legend(ax, 'Location', 'eastoutside');

end