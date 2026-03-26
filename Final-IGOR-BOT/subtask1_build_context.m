function ctx = subtask1_build_context(basePath)
%SUBTASK1_BUILD_CONTEXT Build GUI context using the original mainV.m setup.

if nargin < 1 || isempty(basePath)
    basePath = fileparts(mfilename('fullpath'));
end

ctx = struct();
ctx.basePath = basePath;

addpath(basePath);
addpath(fullfile(basePath, 'occupancyMap'));
addpath(fullfile(basePath, 'visualisation'));
addpath(fullfile(basePath, 'BfsAndDijkstra'));

oldFolder = pwd;
cleanupObj = onCleanup(@() cd(oldFolder));
cd(basePath);

load(fullfile(basePath, 'newMapReadings.mat'));
run(fullfile(basePath, 'occupancyMap', 'AngularV.m'));
close all;
run(fullfile(basePath, 'occupancyMap', 'extractedPoints.m'));
close all;

occData = load(fullfile(basePath, 'occupancyGrid.mat'), 'occGrid', 'cellSize_m', 'nRows', 'nCols');
ctx.occGrid = occData.occGrid;
ctx.cellSize_m = occData.cellSize_m;
ctx.nRows = occData.nRows;
ctx.nCols = occData.nCols;

ctx.mapRef.latTop    = (51.5413023377624 + 51.54128358792175) / 2;
ctx.mapRef.latBottom = (51.53637540808553 + 51.53637740926019) / 2;
ctx.mapRef.lonLeft   = (-0.02113822581864861 + -0.021159663821911742) / 2;
ctx.mapRef.lonRight  = (-0.0053338668458112635 + -0.00531892350591541) / 2;

ctx.keyP = keyP;
ctx.sigP = sigP;
ctx.nodes = createNodesFromTables(keyP, sigP);
ctx.L_bfs = createGraph_BFS(ctx.nodes);
ctx.L_dij = createGraph_Dijkstra(ctx.nodes);
ctx.waitingIdx = getWaitingPointIndices(ctx.nodes);
ctx.waitingNames = string(ctx.nodes.names(ctx.waitingIdx));

ctx.keyLinkedList = i_buildLinkedListFromTable(keyP, "key");
ctx.sigLinkedList = i_buildLinkedListFromTable(sigP, "signal");
ctx.keyKDTree = i_buildKDTreeFromTable(keyP, "key");
ctx.sigKDTree = i_buildKDTreeFromTable(sigP, "signal");

ctx.questionList = {
    '1. Route from Point A to Point B'
    '2. Distance from Point A to Point B'
    '3. Closest key point to Point A'
    '4. 3 closest key points to Point A'
    '5. 2 closest key points to selected waiting area'
    '6. Route from waiting area to Point A and back'
    '7. Route from waiting area to Point A, then Point B, then nearest waiting area'
    '8. Full tourist-guide mode from selected waiting area'
    '9. Show lookup entry for Point A'
    '10. Compare linked list vs KD-tree nearest lookup for Point A'
    };
end

function list = i_buildLinkedListFromTable(T, pointType)
list = struct('head', -1, 'tail', -1, 'nodes', []);
if isempty(T)
    return;
end

n = height(T);
list.nodes = repmat(struct('lat', 0, 'lon', 0, 'label', "", 'type', pointType, 'next', -1, 'prev', -1), n, 1);
for i = 1:n
    list.nodes(i).lat = T.Latitude(i);
    list.nodes(i).lon = T.Longitude(i);
    list.nodes(i).label = string(T.Remark(i));
    list.nodes(i).type = pointType;
    list.nodes(i).prev = i - 1;
    list.nodes(i).next = i + 1;
end
list.nodes(1).prev = -1;
list.nodes(end).next = -1;
list.head = 1;
list.tail = n;
end

function tree = i_buildKDTreeFromTable(T, pointType)
labels = string(T.Remark);
coords = [T.Longitude, T.Latitude];
indices = (1:height(T))';
tree = i_buildKDRecursive(coords, labels, indices, pointType, 0);
end

function node = i_buildKDRecursive(coords, labels, indices, pointType, depth)
if isempty(indices)
    node = [];
    return;
end
axisId = mod(depth, 2) + 1;
[~, order] = sort(coords(indices, axisId));
sortedIdx = indices(order);
mid = ceil(numel(sortedIdx) / 2);
idx = sortedIdx(mid);
node = struct();
node.split_axis = axisId - 1;
node.depth = depth;
node.xvalue = coords(idx, 1);
node.yvalue = coords(idx, 2);
node.label = labels(idx);
node.type = pointType;
node.dataIndex = idx;
node.left = i_buildKDRecursive(coords, labels, sortedIdx(1:mid-1), pointType, depth + 1);
node.right = i_buildKDRecursive(coords, labels, sortedIdx(mid+1:end), pointType, depth + 1);
end
