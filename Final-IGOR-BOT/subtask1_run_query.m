function result = subtask1_run_query(ctx, request)
%SUBTASK1_RUN_QUERY Execute one of the 10 Subtask 1 queries.

qId = request.questionId;
algorithm = string(request.algorithm);
lookupMode = string(request.lookupMode);
pointA = string(request.pointA);
pointB = string(request.pointB);
waitingName = string(request.waitingName);
animateRoute = logical(request.animateRoute);
showRoute = logical(request.showRoute);

result = struct();
result.ok = true;
result.summary = "";
result.routePaths = {};
result.routeColors = {};
result.routeLabels = {};
result.fullRouteRC = [];
result.highlightNodes = [];
result.lookupText = "";
result.compareText = "";
result.answerTable = {};
result.metaRows = {};
result.animateRoute = animateRoute;
result.showRoute = showRoute;

nodeA = i_findAnyNodeByName(ctx.nodes, pointA);
nodeB = i_findAnyNodeByName(ctx.nodes, pointB);
waitNode = i_findAnyNodeByName(ctx.nodes, waitingName);

switch qId
    case 1
        [pathAB, costAB, bigO] = i_runRoute(ctx, nodeA, nodeB, algorithm);
        result.summary = sprintf('Route from %s to %s using %s.', pointA, pointB, algorithm);
        result.answerTable = [result.answerTable; {'Route', strjoin(string(ctx.nodes.names(pathAB)), ' -> ')}];
        result.answerTable = [result.answerTable; {'Cost', i_routeMetricLabel(algorithm, costAB)}];
        result.routePaths = {pathAB};
        result.routeColors = {'r-'};
        result.routeLabels = {'A to B'};
        result.highlightNodes = unique(pathAB(:)');
        result.metaRows = [result.metaRows; {lookupMode, algorithm, bigO}];

    case 2
        [pathAB, costAB, bigO] = i_runRoute(ctx, nodeA, nodeB, algorithm);
        result.summary = sprintf('Distance query from %s to %s.', pointA, pointB);
        result.answerTable = [result.answerTable; {'Path', strjoin(string(ctx.nodes.names(pathAB)), ' -> ')}];
        result.answerTable = [result.answerTable; {'Distance / steps', i_routeMetricLabel(algorithm, costAB)}];
        result.routePaths = {pathAB};
        result.routeColors = {'r-'};
        result.routeLabels = {'Distance query path'};
        result.highlightNodes = unique(pathAB(:)');
        result.metaRows = [result.metaRows; {lookupMode, algorithm, bigO}];

    case 3
        [nearestIdx, nearestDist, lookupBigO] = i_findNearestKey(ctx, nodeA, lookupMode, 1, true);
        result.summary = sprintf('Closest key point to %s.', pointA);
        result.answerTable = [result.answerTable; {'Closest key point', string(ctx.keyP.Remark(nearestIdx))}];
        result.answerTable = [result.answerTable; {'Distance', sprintf('%.2f m', nearestDist)}];
        result.lookupText = i_makeLookupText(ctx, lookupMode, nearestIdx, true);
        result.highlightNodes = i_findNodeSetByNames(ctx.nodes, string(ctx.keyP.Remark(nearestIdx)));
        result.metaRows = [result.metaRows; {lookupMode, '-', lookupBigO}];

    case 4
        [nearestIdx, nearestDist, lookupBigO] = i_findNearestKey(ctx, nodeA, lookupMode, 3, true);
        result.summary = sprintf('3 closest key points to %s.', pointA);
        for i = 1:numel(nearestIdx)
            result.answerTable = [result.answerTable; {sprintf('#%d', i), sprintf('%s (%.2f m)', string(ctx.keyP.Remark(nearestIdx(i))), nearestDist(i))}]; 
        end
        result.lookupText = join(i_makeLookupLinesForMany(ctx, lookupMode, nearestIdx, true), newline);
        result.highlightNodes = i_findNodeSetByNames(ctx.nodes, string(ctx.keyP.Remark(nearestIdx)));
        result.metaRows = [result.metaRows; {lookupMode, '-', lookupBigO}];

    case 5
        [nearestIdx, nearestDist, lookupBigO] = i_findNearestKey(ctx, waitNode, lookupMode, 2, false);
        result.summary = sprintf('2 closest key points to waiting area %s.', waitingName);
        for i = 1:numel(nearestIdx)
            result.answerTable = [result.answerTable; {sprintf('#%d', i), sprintf('%s (%.2f m)', string(ctx.keyP.Remark(nearestIdx(i))), nearestDist(i))}]; 
        end
        result.lookupText = join(i_makeLookupLinesForMany(ctx, lookupMode, nearestIdx, true), newline);
        result.highlightNodes = unique([waitNode, i_findNodeSetByNames(ctx.nodes, string(ctx.keyP.Remark(nearestIdx)))]);
        result.metaRows = [result.metaRows; {lookupMode, '-', lookupBigO}];

    case 6
        [path1, cost1, bigO] = i_runRoute(ctx, waitNode, nodeA, algorithm);
        [path2, cost2, ~] = i_runRoute(ctx, nodeA, waitNode, algorithm);
        result.summary = sprintf('Round trip from %s to %s and back.', waitingName, pointA);
        result.answerTable = [result.answerTable; {'Outward', strjoin(string(ctx.nodes.names(path1)), ' -> ')}];
        result.answerTable = [result.answerTable; {'Return', strjoin(string(ctx.nodes.names(path2)), ' -> ')}];
        result.answerTable = [result.answerTable; {'Total cost', i_routeMetricLabel(algorithm, cost1 + cost2)}];
        result.routePaths = {path1, path2};
        result.routeColors = {'c-', 'm-'};
        result.routeLabels = {'Waiting to A', 'A to waiting'};
        result.highlightNodes = unique([path1(:); path2(:)])';
        result.metaRows = [result.metaRows; {lookupMode, algorithm, bigO}];

    case 7
        [path1, cost1, bigO] = i_runRoute(ctx, waitNode, nodeA, algorithm);
        [path2, cost2, ~] = i_runRoute(ctx, nodeA, nodeB, algorithm);
        returnWait = nearestWaitingPoint(ctx.L_dij, ctx.waitingIdx, nodeB);
        [path3, cost3, ~] = i_runRoute(ctx, nodeB, returnWait, algorithm);
        result.summary = sprintf('Multi-stage trip: %s -> %s -> %s -> nearest waiting.', waitingName, pointA, pointB);
        result.answerTable = [result.answerTable; {'Leg 1', strjoin(string(ctx.nodes.names(path1)), ' -> ')}];
        result.answerTable = [result.answerTable; {'Leg 2', strjoin(string(ctx.nodes.names(path2)), ' -> ')}];
        result.answerTable = [result.answerTable; {'Leg 3', strjoin(string(ctx.nodes.names(path3)), ' -> ')}];
        result.answerTable = [result.answerTable; {'Return waiting', string(ctx.nodes.names{returnWait})}];
        result.answerTable = [result.answerTable; {'Total cost', i_routeMetricLabel(algorithm, cost1 + cost2 + cost3)}];
        result.routePaths = {path1, path2, path3};
        result.routeColors = {'c-', 'r-', 'm-'};
        result.routeLabels = {'Waiting to A', 'A to B', 'B to nearest waiting'};
        result.highlightNodes = unique([path1(:); path2(:); path3(:)])';
        result.metaRows = [result.metaRows; {lookupMode, algorithm, bigO}];

    case 8
        [tourPath, totalCost, visitOrder] = i_fullTourGuide(ctx, waitNode, algorithm);
        result.summary = sprintf('Full tourist-guide mode starting from %s.', waitingName);
        result.answerTable = [result.answerTable; {'Visit order', strjoin(string(ctx.nodes.names(visitOrder)), ' -> ')}];
        result.answerTable = [result.answerTable; {'Expanded path', strjoin(string(ctx.nodes.names(tourPath)), ' -> ')}];
        result.answerTable = [result.answerTable; {'Total cost', i_routeMetricLabel(algorithm, totalCost)}];
        result.routePaths = {tourPath};
        result.routeColors = {'r-'};
        result.routeLabels = {'Full tourist-guide mode'};
        result.highlightNodes = unique(tourPath(:)');
        if algorithm == "BFS"
            routeBigO = 'Approx TSP wrapper: O(K^2(V+E)) + BFS segments';
        else
            routeBigO = 'Approx TSP wrapper: O(K^2(V+E)logV) + Dijkstra segments';
        end
        result.metaRows = [result.metaRows; {lookupMode, algorithm, routeBigO}];

    case 9
        result.summary = sprintf('Lookup entry for %s.', pointA);
        keyIdx = find(strcmpi(string(ctx.keyP.Remark), char(pointA)), 1);
        if ~isempty(keyIdx)
            result.lookupText = i_makeLookupText(ctx, lookupMode, keyIdx, true);
        else
            result.lookupText = sprintf(['%s is a signal/non-key node.\n' ...
                'The linked-list and KD-tree viewers are built over key points for Subtask 1 comparison,\n' ...
                'so this entry is shown as a plain graph-node record instead.\n' ...
                '%s'], pointA, i_makeLookupText(ctx, lookupMode, nodeA, false));
        end
        result.answerTable = [result.answerTable; {'Lookup structure', char(lookupMode)}];
        result.answerTable = [result.answerTable; {'Entry', result.lookupText}];
        result.highlightNodes = i_findNodeSetByNames(ctx.nodes, pointA);
        result.metaRows = [result.metaRows; {lookupMode, '-', i_lookupBigO(lookupMode, 1)}];

    case 10
        t1 = tic;
        [listIdx, listDist] = i_findNearestKey(ctx, nodeA, "Linked List", 1, false);
        listTime = toc(t1) * 1000;
        t2 = tic;
        [kdIdx, kdDist] = i_findNearestKey(ctx, nodeA, "KD-Tree", 1, false);
        kdTime = toc(t2) * 1000;
        result.summary = sprintf('Nearest-neighbour lookup comparison for %s.', pointA);
        result.answerTable = [result.answerTable; {'Linked list result', sprintf('%s (%.2f m)', string(ctx.keyP.Remark(listIdx)), listDist)}];
        result.answerTable = [result.answerTable; {'Linked list time', sprintf('%.3f ms', listTime)}];
        result.answerTable = [result.answerTable; {'KD-tree result', sprintf('%s (%.2f m)', string(ctx.keyP.Remark(kdIdx)), kdDist)}];
        result.answerTable = [result.answerTable; {'KD-tree time', sprintf('%.3f ms', kdTime)}];
        result.compareText = sprintf(['Linked list scans every key point, so it is O(n).\n' ...
            'KD-tree nearest-neighbour prunes search branches, so average lookup is O(log n), with O(n) worst case.']);
        result.lookupText = sprintf('List: %s\nKD-tree: %s', ...
            i_makeLookupText(ctx, "Linked List", listIdx, true), ...
            i_makeLookupText(ctx, "KD-Tree", kdIdx, true));
        result.highlightNodes = i_findNodeSetByNames(ctx.nodes, string(ctx.keyP.Remark([listIdx kdIdx])));
        result.metaRows = [result.metaRows; {"Linked List", '-', 'O(n)'}; {"KD-Tree", '-', 'Avg O(log n), worst O(n)'}];

    otherwise
        error('Unknown question ID: %d', qId);
end

if ~isempty(result.routePaths)
    allSegs = cell(size(result.routePaths));
    for i = 1:numel(result.routePaths)
        allSegs{i} = buildDetailedRoute(result.routePaths{i}, ctx.nodes, ctx.mapRef, ctx.occGrid);
    end
    result.fullRouteRC = concatenateRoutes(allSegs{:});
end
end

function [path, cost, bigO] = i_runRoute(ctx, startNode, goalNode, algorithm)
switch upper(char(algorithm))
    case 'BFS'
        [path, steps] = bfsShortestPath(ctx.L_bfs, startNode, goalNode);
        cost = steps;
        bigO = 'O(V + E)';
    case 'DIJKSTRA'
        [path, cost] = dijkstraShortestPath(ctx.L_dij, startNode, goalNode);
        bigO = 'O(V^2) in this repo implementation';
    case 'DIJKSTRA + PQ'
        [path, cost] = dijkstraPQ(ctx.L_dij, startNode, goalNode);
        bigO = 'O((V + E) log V) expected';
    otherwise
        error('Unknown route algorithm: %s', algorithm);
end
end

function [tourPath, totalCost, visitOrder] = i_fullTourGuide(ctx, startWaitingNode, algorithm)
remaining = 1:ctx.nodes.nKey;
keyNames = string(ctx.keyP.Remark);
visitOrder = startWaitingNode;
currentNode = startWaitingNode;
totalCost = 0;
fullPath = currentNode;

while ~isempty(remaining)
    keyNodeIds = zeros(size(remaining));
    for i = 1:numel(remaining)
        keyNodeIds(i) = i_findAnyNodeByName(ctx.nodes, keyNames(remaining(i)));
    end

    bestCost = inf;
    bestIdx = remaining(1);
    bestPath = [];
    for i = 1:numel(keyNodeIds)
        [candPath, candCost] = i_runRoute(ctx, currentNode, keyNodeIds(i), algorithm);
        if candCost < bestCost
            bestCost = candCost;
            bestIdx = remaining(i);
            bestPath = candPath;
        end
    end

    if numel(fullPath) > 0 && numel(bestPath) > 1
        fullPath = [fullPath, bestPath(2:end)];
    else
        fullPath = [fullPath, bestPath];
    end
    totalCost = totalCost + bestCost;
    currentNode = i_findAnyNodeByName(ctx.nodes, keyNames(bestIdx));
    visitOrder(end+1) = currentNode; 
    remaining(remaining == bestIdx) = [];
end

returnWait = nearestWaitingPoint(ctx.L_dij, ctx.waitingIdx, currentNode);
[backPath, backCost] = i_runRoute(ctx, currentNode, returnWait, algorithm);
if numel(backPath) > 1
    fullPath = [fullPath, backPath(2:end)]; 
end
totalCost = totalCost + backCost;
visitOrder(end+1) = returnWait;
tourPath = fullPath;
end

function [idxs, dists, bigO] = i_findNearestKey(ctx, referenceNode, lookupMode, k, referenceIsKeyOnly)
refCoord = ctx.nodes.coords(referenceNode, :);

if nargin < 5
    referenceIsKeyOnly = false;
end

switch char(lookupMode)
    case 'Linked List'
        [idxs, dists] = i_linkedListNearest(ctx.keyLinkedList, refCoord, k, referenceIsKeyOnly, ctx.keyP);
        bigO = i_lookupBigO(lookupMode, k);
    case 'KD-Tree'
        [idxs, dists] = i_kdNearest(ctx.keyKDTree, refCoord, k, referenceIsKeyOnly, ctx.keyP);
        bigO = i_lookupBigO(lookupMode, k);
    otherwise
        error('Unknown lookup mode: %s', lookupMode);
end
end

function [idxs, dists] = i_linkedListNearest(list, refCoord, k, referenceIsKeyOnly, keyP)
current = list.head;
rows = [];
while current ~= -1
    label = string(list.nodes(current).label);
    lat = list.nodes(current).lat;
    lon = list.nodes(current).lon;
    if ~(referenceIsKeyOnly && abs(lat - refCoord(1)) < 1e-12 && abs(lon - refCoord(2)) < 1e-12)
        d = latlonDistanceMeters(refCoord(1), refCoord(2), lat, lon);
        rows = [rows; current, d]; 
    end
    current = list.nodes(current).next;
end
[~, order] = sort(rows(:,2), 'ascend');
rows = rows(order,:);
rows = rows(1:min(k, size(rows,1)), :);
idxs = rows(:,1)';
dists = rows(:,2)';

% keep indices consistent with keyP ordering
allLabels = string(keyP.Remark);
for i = 1:numel(idxs)
    idxs(i) = find(allLabels == string(list.nodes(idxs(i)).label), 1);
end
end

function [idxs, dists] = i_kdNearest(tree, refCoord, k, referenceIsKeyOnly, keyP)
best = repmat(struct('idx', 0, 'dist', inf), max(k, 1), 1);
bestCount = 0;
searchPoint = [refCoord(2), refCoord(1)]; % x=lon, y=lat

    function visit(node)
        if isempty(node)
            return;
        end
        nodePoint = [node.xvalue, node.yvalue];
        axisId = node.split_axis + 1;
        thisDist = latlonDistanceMeters(searchPoint(2), searchPoint(1), nodePoint(2), nodePoint(1));
        sameAsRef = abs(nodePoint(2) - refCoord(1)) < 1e-12 && abs(nodePoint(1) - refCoord(2)) < 1e-12;
        if ~(referenceIsKeyOnly && sameAsRef)
            [best, bestCount] = updateBest(best, bestCount, node.dataIndex, thisDist);
        end

        if searchPoint(axisId) < nodePoint(axisId)
            nearChild = node.left;
            farChild = node.right;
        else
            nearChild = node.right;
            farChild = node.left;
        end

        visit(nearChild);

        worstAllowed = inf;
        if bestCount >= k
            worstAllowed = max([best(1:k).dist]);
        end
        planeGap = abs(searchPoint(axisId) - nodePoint(axisId)) * 111320; % rough prune distance in m
        if planeGap <= worstAllowed || bestCount < k
            visit(farChild);
        end
    end

    function [bestLocal, countLocal] = updateBest(bestLocal, countLocal, idxLocal, distLocal)
        if countLocal < k
            countLocal = countLocal + 1;
            bestLocal(countLocal).idx = idxLocal;
            bestLocal(countLocal).dist = distLocal;
        else
            [worstDist, worstPos] = max([bestLocal(1:k).dist]);
            if distLocal < worstDist
                bestLocal(worstPos).idx = idxLocal;
                bestLocal(worstPos).dist = distLocal;
            end
        end
    end

visit(tree);
valid = [best.idx] > 0;
arrIdx = [best(valid).idx];
arrDist = [best(valid).dist];
[~, order] = sort(arrDist, 'ascend');
idxs = arrIdx(order);
dists = arrDist(order);
idxs = idxs(1:min(k, numel(idxs)));
dists = dists(1:min(k, numel(dists)));

% indices already match keyP ordering because the tree was built from keyP
idxs = idxs(:)';
dists = dists(:)';

% filter exact self match again just in case
if referenceIsKeyOnly
    keep = true(size(idxs));
    for i = 1:numel(idxs)
        keep(i) = ~(abs(keyP.Latitude(idxs(i)) - refCoord(1)) < 1e-12 && abs(keyP.Longitude(idxs(i)) - refCoord(2)) < 1e-12);
    end
    idxs = idxs(keep);
    dists = dists(keep);
end
end

function idx = i_findAnyNodeByName(nodes, nameStr)
idx = find(strcmpi(nodes.names, char(nameStr)), 1);
if isempty(idx)
    error('Node "%s" not found.', nameStr);
end
end

function idx = i_nameToKeyIndex(ctx, nameStr)
idx = find(strcmpi(string(ctx.keyP.Remark), char(nameStr)), 1);
if isempty(idx)
    error('"%s" is not a key point.', nameStr);
end
end

function s = i_makeLookupText(ctx, lookupMode, keyIdx, isKeyIdx)
if nargin < 4
    isKeyIdx = true;
end
if isKeyIdx
    label = string(ctx.keyP.Remark(keyIdx));
    lat = ctx.keyP.Latitude(keyIdx);
    lon = ctx.keyP.Longitude(keyIdx);
else
    label = string(ctx.nodes.names{keyIdx});
    lat = ctx.nodes.coords(keyIdx,1);
    lon = ctx.nodes.coords(keyIdx,2);
end
switch char(lookupMode)
    case 'Linked List'
        prevTxt = 'prev -> sequential node';
        nextTxt = 'next -> sequential node';
        s = sprintf('LinkedList node | %s | lat=%.6f lon=%.6f | %s | %s', label, lat, lon, prevTxt, nextTxt);
    case 'KD-Tree'
        s = sprintf('KDTree node | %s | lat=%.6f lon=%.6f | split=%s', label, lat, lon, 'alternating x/y');
    otherwise
        s = sprintf('%s | lat=%.6f lon=%.6f', label, lat, lon);
end
end

function lines = i_makeLookupLinesForMany(ctx, lookupMode, idxs, isKeyIdx)
lines = strings(1, numel(idxs));
for i = 1:numel(idxs)
    lines(i) = string(i_makeLookupText(ctx, lookupMode, idxs(i), isKeyIdx));
end
end

function nodeIds = i_findNodeSetByNames(nodes, names)
if ischar(names) || isstring(names)
    names = string(names);
end
nodeIds = [];
for i = 1:numel(names)
    idx = find(strcmpi(nodes.names, char(names(i))), 1);
    if ~isempty(idx)
        nodeIds(end+1) = idx;
    end
end
nodeIds = unique(nodeIds);
end

function label = i_routeMetricLabel(algorithm, value)
if any(strcmpi(char(algorithm), {'Dijkstra', 'Dijkstra + PQ'}))
    label = sprintf('%.2f m', value);
else
    label = sprintf('%d steps', round(value));
end
end

function bigO = i_lookupBigO(lookupMode, k)
if nargin < 2
    k = 1;
end
switch char(lookupMode)
    case 'Linked List'
        if k == 1
            bigO = 'O(n)';
        else
            bigO = 'O(n log n) with sort for k-NN';
        end
    case 'KD-Tree'
        if k == 1
            bigO = 'Average O(log n), worst O(n)';
        else
            bigO = 'Average O(log n + k), worst O(n)';
        end
    otherwise
        bigO = '-';
end
end
