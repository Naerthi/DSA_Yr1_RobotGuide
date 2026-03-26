function render_subtask1_map(ax, ctx, result)
%RENDER_SUBTASK1_MAP Draw Subtask 1 on the repo's generated map.
% Uses the existing occupancy-grid style map already generated in the repo,
% not the realistic satellite image. By default it only shows the points.
% Route/path overlays are drawn only when a query returns them.

if nargin < 3 || isempty(result)
    result = struct();
end

axes(ax); 
cla(ax);
hold(ax, 'on');
box(ax, 'on');

imagesc(ax, ctx.occGrid);
axis(ax, 'image');
set(ax, 'XDir', 'normal');
set(ax, 'YDir', 'reverse');
colormap(ax, [1 1 1; 0 0.60 0]);
caxis(ax, [0 1]);

coords = ctx.nodes.coords;
xy = zeros(ctx.nodes.nTotal, 2);
for i = 1:ctx.nodes.nTotal
    [r, c] = latlonToGridRC(coords(i,1), coords(i,2), ctx.mapRef, ctx.occGrid);
    xy(i,:) = [c, r];
end

% Optional graph connections only when explicitly requested.
showConnections = isfield(result, 'showConnections') && result.showConnections;
if showConnections
    plotted = false(ctx.nodes.nTotal);
    for i = 1:numel(ctx.graph)
        neighbors = ctx.graph{i}(:,1);
        for k = 1:numel(neighbors)
            j = neighbors(k);
            if ~plotted(i,j)
                plot(ax, [xy(i,1) xy(j,1)], [xy(i,2) xy(j,2)], '-', ...
                    'Color', [0.55 0.55 0.55], 'LineWidth', 1.0, ...
                    'HandleVisibility', 'off');
                plotted(i,j) = true;
                plotted(j,i) = true;
            end
        end
    end
end

% Path overlay only after a path-producing query.
if isfield(result, 'secondaryPathNodes') && ~isempty(result.secondaryPathNodes)
    styles = {'m-', 'r-', 'c-'};
    for i = 1:numel(result.secondaryPathNodes)
        p = result.secondaryPathNodes{i};
        if ~isempty(p)
            draw_node_path_grid(ax, ctx, p, styles{min(i,numel(styles))}, 2.6);
        end
    end
elseif isfield(result, 'pathNodes') && ~isempty(result.pathNodes)
    draw_node_path_grid(ax, ctx, result.pathNodes, 'm-', 2.8);
end

sigIdx = (ctx.nodes.nKey + 1):ctx.nodes.nTotal;
plot(ax, xy(sigIdx,1), xy(sigIdx,2), 'bo', ...
    'MarkerFaceColor', 'b', 'MarkerSize', 5, 'DisplayName', 'Signal point');

keyIdx = 1:ctx.nodes.nKey;
plot(ax, xy(keyIdx,1), xy(keyIdx,2), 'ro', ...
    'MarkerFaceColor', 'r', 'MarkerSize', 6, 'DisplayName', 'Key point');

plot(ax, xy(ctx.waitingIdx,1), xy(ctx.waitingIdx,2), 'gs', ...
    'MarkerFaceColor', 'g', 'MarkerSize', 8, 'DisplayName', 'Waiting point');

if isfield(result, 'highlightNodes') && ~isempty(result.highlightNodes)
    idx = unique(result.highlightNodes(:)');
    plot(ax, xy(idx,1), xy(idx,2), 'ko', 'MarkerSize', 11, ...
        'LineWidth', 1.5, 'HandleVisibility', 'off');
end

for i = 1:ctx.nodes.nTotal
    text(ax, xy(i,1)+1.5, xy(i,2), ctx.nodes.names{i}, 'FontSize', 8, 'Color', 'k');
end

title(ax, 'Generated map with key points and signal points');
xlabel(ax, 'Grid Column');
ylabel(ax, 'Grid Row');
legend(ax, 'Location', 'eastoutside');
hold(ax, 'off');
end

function draw_node_path_grid(ax, ctx, pathNodes, lineSpec, lineWidth)
if isempty(pathNodes)
    return;
end
xy = zeros(numel(pathNodes), 2);
for i = 1:numel(pathNodes)
    idx = pathNodes(i);
    [r, c] = latlonToGridRC(ctx.nodes.coords(idx,1), ctx.nodes.coords(idx,2), ctx.mapRef, ctx.occGrid);
    xy(i,:) = [c, r];
end
plot(ax, xy(:,1), xy(:,2), lineSpec, 'LineWidth', lineWidth, 'HandleVisibility', 'off');
end
