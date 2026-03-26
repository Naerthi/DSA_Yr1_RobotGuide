allData = [keyP; sigP];

latitudes = allData{:,1};
longitudes = allData{:,2};
labels = string(allData{:,3});

% Create type labels
types = [repmat("key", height(keyP), 1); ...
         repmat("signal", height(sigP), 1)];


% BUILD KD TREE

graph = [];
split_axis = 0;

for i = 1:length(latitudes)
    lat = latitudes(i);
    lon = longitudes(i);

    [kdNode, split_axis] = createKdnode(lon, lat, labels(i), types(i), split_axis);
    graph = insertKdnode(graph, kdNode);
end


% PLOT TREE STRUCTURE

figure('Color','k');
plotKdTree(graph);
title('KD-Tree Structure');


% PLOT KD SPACE (REAL COORDS)

xmin = min(longitudes);
xmax = max(longitudes);
ymin = min(latitudes);
ymax = max(latitudes);

figure; hold on; axis equal;
plotKdSpace(graph, xmin, xmax, ymin, ymax);
title('KD-Tree Spatial Partitioning');

% Legend
plot(nan,nan,'ro','MarkerFaceColor','r');
plot(nan,nan,'go','MarkerFaceColor','g');
legend('Key Points','Signal Points');



% FUNCTIONS


function [kdNode, split_axis] = createKdnode(xval, yval, label, type, split_axis)
    kdNode = struct( ...
        "split_axis", split_axis, ...
        "xvalue", xval, ...
        "yvalue", yval, ...
        "label", label, ...
        "type", type, ...
        "left", [], ...
        "right", []);
    
    split_axis = ~split_axis;
end


function graph = insertKdnode(graph, kdNode)
    if isempty(graph)
        graph = kdNode;
        return;
    end
    
    split_axis = graph.split_axis;

    if split_axis == 0
        if kdNode.xvalue < graph.xvalue
            graph.left = insertKdnode(graph.left, kdNode);
        else
            graph.right = insertKdnode(graph.right, kdNode);
        end
    else
        if kdNode.yvalue < graph.yvalue
            graph.left = insertKdnode(graph.left, kdNode);
        else
            graph.right = insertKdnode(graph.right, kdNode);
        end
    end
end


function plotKdTree(root)
    clf;
    hold on;
    axis off;
    set(gca,'Color','k');

    if isempty(root)
        return;
    end

    plotNode(root, 0, 0, 10);
end


function plotNode(node, x, y, dx)

    % Color based on type
    if node.type == "key"
        color = 'r';
    else
        color = 'g';
    end

    plot(x, y, 'o', 'MarkerFaceColor', color, 'MarkerEdgeColor','w');

    text(x+0.3, y, sprintf('%s\n(%.5f, %.5f)', ...
        node.label, node.xvalue, node.yvalue), ...
        'Color','w');

    if ~isempty(node.left)
        xL = x - dx;
        yL = y - 5;
        plot([x, xL], [y, yL], 'w-');
        plotNode(node.left, xL, yL, dx/1.5);
    end

    if ~isempty(node.right)
        xR = x + dx;
        yR = y - 5;
        plot([x, xR], [y, yR], 'w-');
        plotNode(node.right, xR, yR, dx/1.5);
    end
end


function plotKdSpace(node, xmin, xmax, ymin, ymax)
    if isempty(node)
        return;
    end

    hold on;

    % Choose color based on type
    if node.type == "key"
        pointColor = 'r';
    else
        pointColor = 'g';
    end

    if node.split_axis == 0
        % Vertical split
        x = node.xvalue;
        plot([x x], [ymin ymax], 'r-', 'LineWidth', 1.5);
        plot(x, node.yvalue, 'o', 'MarkerFaceColor', pointColor, 'MarkerEdgeColor','k');

        plotKdSpace(node.left, xmin, x, ymin, ymax);
        plotKdSpace(node.right, x, xmax, ymin, ymax);

    else
        % Horizontal split
        y = node.yvalue;
        plot([xmin xmax], [y y], 'b-', 'LineWidth', 1.5);
        plot(node.xvalue, y, 'o', 'MarkerFaceColor', pointColor, 'MarkerEdgeColor','k');

        plotKdSpace(node.left, xmin, xmax, ymin, y);
        plotKdSpace(node.right, xmin, xmax, y, ymax);
    end
end