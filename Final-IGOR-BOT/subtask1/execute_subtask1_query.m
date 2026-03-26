function result = execute_subtask1_query(ctx, inputs)
%EXECUTE_SUBTASK1_QUERY Run one of the 10 Subtask 1 questions.
% Captures live timings for the exact operations executed by the query.

result = struct();
result.highlightNodes = [];
result.pathNodes = [];
result.secondaryPathNodes = {};
result.extraPoints = [];
result.text = '';
result.complexityText = complexity_summary_text();
result.liveTimings = empty_live_timings();
result.showConnections = false;

switch inputs.queryId
    case 1
        startNode = findNodeByName(ctx.nodes, inputs.pointA);
        goalNode = findNodeByName(ctx.nodes, inputs.pointB);
        t0 = tic;
        [pathNodes, totalCost, algoLabel] = solve_path(ctx, startNode, goalNode, inputs.algorithmId);
        elapsedMs = toc(t0) * 1000;
        result.liveTimings = append_live_timing(result.liveTimings, algo_operation_name(inputs.algorithmId), elapsedMs, algo_complexity(inputs.algorithmId), mem_path(pathNodes));
        result.highlightNodes = [startNode goalNode];
        result.pathNodes = pathNodes;
        result.text = sprintf(['Q1 How to get to point A from point B?\n' ...
            'Algorithm: %s\n' ...
            'Route: %s\n' ...
            'Cost: %.2f m\n' ...
            'Live query timing: %.4f ms'], ...
            algoLabel, join_names(ctx.nodes.names(pathNodes)), totalCost, elapsedMs);

    case 2
        startNode = findNodeByName(ctx.nodes, inputs.pointA);
        goalNode = findNodeByName(ctx.nodes, inputs.pointB);
        t0 = tic;
        [~, totalCost, algoLabel] = solve_path(ctx, startNode, goalNode, inputs.algorithmId);
        graphMs = toc(t0) * 1000;
        result.liveTimings = append_live_timing(result.liveTimings, algo_operation_name(inputs.algorithmId), graphMs, algo_complexity(inputs.algorithmId), 'Stores frontier + predecessor arrays');
        t1 = tic;
        direct = latlonDistanceMeters(ctx.nodes.coords(startNode,1), ctx.nodes.coords(startNode,2), ...
            ctx.nodes.coords(goalNode,1), ctx.nodes.coords(goalNode,2));
        directMs = toc(t1) * 1000;
        result.liveTimings = append_live_timing(result.liveTimings, 'Straight-line distance', directMs, 'O(1)', 'Two coordinate pairs');
        result.highlightNodes = [startNode goalNode];
        result.text = sprintf(['Q2 Distance from point A to point B\n' ...
            'Graph distance using %s: %.2f m\n' ...
            'Straight-line distance: %.2f m'], ...
            algoLabel, totalCost, direct);

    case 3
        refNode = findNodeByName(ctx.nodes, inputs.pointA);
        refLat = ctx.nodes.coords(refNode,1);
        refLon = ctx.nodes.coords(refNode,2);
        t0 = tic;
        kdItems = kd_k_nearest_keys(ctx.kdTree, refLat, refLon, max(inputs.k + 1, inputs.k));
        kdMs = toc(t0) * 1000;
        t1 = tic;
        listItems = list_all_key_distances(ctx.linkedList, refLat, refLon);
        listMs = toc(t1) * 1000;
        result.liveTimings = append_live_timing(result.liveTimings, 'KD-tree nearest lookup', kdMs, 'Average O(log n), worst O(n)', sprintf('KD tree with %d key points', ctx.nodes.nKey));
        result.liveTimings = append_live_timing(result.liveTimings, 'Linked-list full scan', listMs, 'O(n)', sprintf('Linked list with %d key points', ctx.nodes.nKey));
        kdItems = remove_self_if_present(kdItems, ctx.nodes.names{refNode});
        kdItems = kdItems(1:min(inputs.k, numel(kdItems)));
        listItems = remove_self_if_present(listItems, ctx.nodes.names{refNode});
        listItems = listItems(1:min(inputs.k, numel(listItems)));
        result.highlightNodes = [refNode; find_nodes_by_names(ctx, string({kdItems.name}))'];
        result.text = sprintf(['Q3 Guide me to the k closest key points from %s\n' ...
            'KD-tree answer: %s\n' ...
            'Linked-list check: %s\n' ...
            'Live timings: KD-tree %.4f ms, linked-list %.4f ms'], ...
            ctx.nodes.names{refNode}, format_distance_list(kdItems), format_distance_list(listItems), kdMs, listMs);

    case 4
        waitNode = inputs.waitingNode;
        result = nearest_keys_from_node(ctx, waitNode, 2, sprintf('Q4 Two closest key points to %s', ctx.nodes.names{waitNode}));

    case 5
        waitNode = inputs.waitingNode;
        result = nearest_keys_from_node(ctx, waitNode, 2, sprintf('Q5 Two closest key points to %s', ctx.nodes.names{waitNode}));

    case 6
        refNode = findNodeByName(ctx.nodes, inputs.pointA);
        result = nearest_keys_from_node(ctx, refNode, 1, sprintf('Q6 Closest key point to %s', ctx.nodes.names{refNode}));

    case 7
        refNode = findNodeByName(ctx.nodes, inputs.pointA);
        t0 = tic;
        nearestWaitNode = nearestWaitingPoint(ctx.graph, ctx.waitingIdx, refNode);
        nearestWaitMs = toc(t0) * 1000;
        result.liveTimings = append_live_timing(result.liveTimings, 'Nearest waiting-point search', nearestWaitMs, 'O(w)', sprintf('Checks %d waiting points', numel(ctx.waitingIdx)));
        t1 = tic;
        [pathNodes, totalCost] = dijkstra_heap(ctx.graph, refNode, nearestWaitNode);
        pqMs = toc(t1) * 1000;
        result.liveTimings = append_live_timing(result.liveTimings, 'Dijkstra (priority queue)', pqMs, 'O((V + E) log V)', mem_path(pathNodes));
        result.highlightNodes = [refNode nearestWaitNode];
        result.pathNodes = pathNodes;
        result.text = sprintf(['Q7 Nearest waiting point to %s\n' ...
            'Nearest waiting point: %s\n' ...
            'Return route: %s\n' ...
            'Distance: %.2f m'], ...
            ctx.nodes.names{refNode}, ctx.nodes.names{nearestWaitNode}, join_names(ctx.nodes.names(pathNodes)), totalCost);

    case 8
        startNode = findNodeByName(ctx.nodes, inputs.pointA);
        goalNode = findNodeByName(ctx.nodes, inputs.pointB);
        startWait = inputs.waitingNode;
        t1 = tic; [path1, d1] = dijkstra_heap(ctx.graph, startWait, startNode); ms1 = toc(t1) * 1000;
        t2 = tic; [path2, d2] = dijkstra_heap(ctx.graph, startNode, goalNode); ms2 = toc(t2) * 1000;
        t3 = tic; [path3, d3] = dijkstra_heap(ctx.graph, goalNode, startWait); ms3 = toc(t3) * 1000;
        result.liveTimings = append_live_timing(result.liveTimings, 'Dijkstra (priority queue) wait->A', ms1, 'O((V + E) log V)', mem_path(path1));
        result.liveTimings = append_live_timing(result.liveTimings, 'Dijkstra (priority queue) A->B', ms2, 'O((V + E) log V)', mem_path(path2));
        result.liveTimings = append_live_timing(result.liveTimings, 'Dijkstra (priority queue) B->wait', ms3, 'O((V + E) log V)', mem_path(path3));
        result.highlightNodes = [startWait startNode goalNode];
        result.pathNodes = path2;
        result.secondaryPathNodes = {path1, path2, path3};
        result.text = sprintf(['Q8 Full route\n' ...
            'Waiting -> A: %s (%.2f m)\n' ...
            'A -> B: %s (%.2f m)\n' ...
            'B -> waiting: %s (%.2f m)\n' ...
            'Total route length: %.2f m'], ...
            join_names(ctx.nodes.names(path1)), d1, join_names(ctx.nodes.names(path2)), d2, ...
            join_names(ctx.nodes.names(path3)), d3, d1 + d2 + d3);

    case 9
        startNode = findNodeByName(ctx.nodes, inputs.pointA);
        goalNode = findNodeByName(ctx.nodes, inputs.pointB);
        t0 = tic; [pathBFS, stepsBFS] = bfsShortestPath(ctx.graph, startNode, goalNode); tBFS = toc(t0) * 1000;
        t1 = tic; [pathD, distD] = dijkstraShortestPath(ctx.graph, startNode, goalNode); tD = toc(t1) * 1000;
        t2 = tic; [pathPQ, distPQ] = dijkstra_heap(ctx.graph, startNode, goalNode); tPQ = toc(t2) * 1000;
        result.liveTimings = append_live_timing(result.liveTimings, 'BFS path search', tBFS, 'O(V + E)', mem_path(pathBFS));
        result.liveTimings = append_live_timing(result.liveTimings, 'Dijkstra (normal)', tD, 'O(V^2 + E)', mem_path(pathD));
        result.liveTimings = append_live_timing(result.liveTimings, 'Dijkstra (priority queue)', tPQ, 'O((V + E) log V)', mem_path(pathPQ));
        result.highlightNodes = [startNode goalNode];
        result.pathNodes = pathPQ;
        result.secondaryPathNodes = {pathBFS, pathD, pathPQ};
        result.text = sprintf(['Q9 Compare graph searches from %s to %s\n' ...
            'BFS: %s | steps = %d | %.4f ms\n' ...
            'Dijkstra normal: %s | %.2f m | %.4f ms\n' ...
            'Dijkstra + binary heap PQ: %s | %.2f m | %.4f ms'], ...
            ctx.nodes.names{startNode}, ctx.nodes.names{goalNode}, join_names(ctx.nodes.names(pathBFS)), stepsBFS, tBFS, ...
            join_names(ctx.nodes.names(pathD)), distD, tD, join_names(ctx.nodes.names(pathPQ)), distPQ, tPQ);
        result.complexityText = sprintf(['%s\n' ...
            'This query highlights BFS O(V+E), Dijkstra without PQ O(V^2 + E), and Dijkstra+PQ O((V+E)logV).'], complexity_summary_text());

    case 10
        refNode = findNodeByName(ctx.nodes, inputs.pointA);
        t0 = tic;
        items = list_all_key_distances(ctx.linkedList, ctx.nodes.coords(refNode,1), ctx.nodes.coords(refNode,2));
        listMs = toc(t0) * 1000;
        result.liveTimings = append_live_timing(result.liveTimings, 'Linked-list full scan', listMs, 'O(n)', sprintf('Linked list with %d key points', ctx.nodes.nKey));
        items = remove_self_if_present(items, ctx.nodes.names{refNode});
        result.highlightNodes = [refNode; find_nodes_by_names(ctx, string({items.name}))'];
        result.text = sprintf(['Q10 All key points sorted by distance from %s\n' ...
            '%s\n' ...
            'Live linked-list timing: %.4f ms'], ...
            ctx.nodes.names{refNode}, format_distance_list(items), listMs);

    otherwise
        error('Unknown query selection.');
end
end

function result = nearest_keys_from_node(ctx, nodeIdx, k, titleLine)
refLat = ctx.nodes.coords(nodeIdx,1);
refLon = ctx.nodes.coords(nodeIdx,2);
t0 = tic; kdItems = kd_k_nearest_keys(ctx.kdTree, refLat, refLon, max(k + 1, k)); kdMs = toc(t0) * 1000;
t1 = tic; listItems = list_all_key_distances(ctx.linkedList, refLat, refLon); listMs = toc(t1) * 1000;
kdItems = remove_self_if_present(kdItems, ctx.nodes.names{nodeIdx});
listItems = remove_self_if_present(listItems, ctx.nodes.names{nodeIdx});
kdItems = kdItems(1:min(k, numel(kdItems)));
listItems = listItems(1:min(k, numel(listItems)));
result = struct();
result.highlightNodes = [nodeIdx; find_nodes_by_names(ctx, string({kdItems.name}))'];
result.pathNodes = [];
result.secondaryPathNodes = {};
result.extraPoints = [];
result.liveTimings = empty_live_timings();
result.liveTimings = append_live_timing(result.liveTimings, 'KD-tree nearest lookup', kdMs, 'Average O(log n), worst O(n)', sprintf('KD tree with %d key points', ctx.nodes.nKey));
result.liveTimings = append_live_timing(result.liveTimings, 'Linked-list full scan', listMs, 'O(n)', sprintf('Linked list with %d key points', ctx.nodes.nKey));
result.text = sprintf(['%s\n' ...
    'Reference point: %s\n' ...
    'KD-tree: %s\n' ...
    'Linked-list check: %s\n' ...
    'Live timings: KD %.4f ms, list %.4f ms'], ...
    titleLine, ctx.nodes.names{nodeIdx}, format_distance_list(kdItems), format_distance_list(listItems), kdMs, listMs);
result.complexityText = complexity_summary_text();
result.showConnections = false;
end

function [pathNodes, totalCost, label] = solve_path(ctx, startNode, goalNode, algorithmId)
switch algorithmId
    case 1
        [pathNodes, steps] = bfsShortestPath(ctx.graph, startNode, goalNode);
        totalCost = path_length_from_nodes(ctx, pathNodes);
        label = sprintf('BFS (unweighted steps=%d)', steps);
    case 2
        [pathNodes, totalCost] = dijkstraShortestPath(ctx.graph, startNode, goalNode);
        label = 'Dijkstra (normal linear extract-min)';
    case 3
        [pathNodes, totalCost] = dijkstra_heap(ctx.graph, startNode, goalNode);
        label = 'Dijkstra (binary heap priority queue)';
    otherwise
        error('Unknown algorithm selection.');
end
end

function d = path_length_from_nodes(ctx, pathNodes)
d = 0;
for i = 1:max(0, numel(pathNodes)-1)
    a = pathNodes(i);
    b = pathNodes(i+1);
    d = d + latlonDistanceMeters(ctx.nodes.coords(a,1), ctx.nodes.coords(a,2), ctx.nodes.coords(b,1), ctx.nodes.coords(b,2));
end
end

function txt = join_names(names)
if isempty(names)
    txt = '(no route)';
else
    txt = strjoin(cellstr(string(names)), ' -> ');
end
end

function txt = format_distance_list(items)
if isempty(items)
    txt = '(none)';
    return;
end
parts = strings(1, numel(items));
for i = 1:numel(items)
    parts(i) = sprintf('%s (%.2f m)', string(items(i).name), items(i).distance);
end
txt = strjoin(cellstr(parts), ', ');
end

function items = remove_self_if_present(items, selfName)
if isempty(items)
    return;
end
keep = true(1, numel(items));
for i = 1:numel(items)
    keep(i) = ~strcmpi(string(items(i).name), string(selfName));
end
items = items(keep);
end

function idx = find_nodes_by_names(ctx, names)
idx = zeros(1, numel(names));
for i = 1:numel(names)
    idx(i) = findNodeByName(ctx.nodes, names(i));
end
end

function timings = empty_live_timings()
timings = struct('operation', {}, 'timeMs', {}, 'complexity', {}, 'memoryText', {});
end

function timings = append_live_timing(timings, operation, timeMs, complexity, memoryText)
if nargin < 5 || isempty(memoryText)
    memoryText = '-';
end
entry.operation = char(string(operation));
entry.timeMs = double(timeMs);
entry.complexity = char(string(complexity));
entry.memoryText = char(string(memoryText));
timings(end+1) = entry; 
end

function label = algo_operation_name(algorithmId)
switch algorithmId
    case 1
        label = 'BFS path search';
    case 2
        label = 'Dijkstra (normal)';
    case 3
        label = 'Dijkstra (priority queue)';
    otherwise
        label = 'Path search';
end
end

function txt = algo_complexity(algorithmId)
switch algorithmId
    case 1
        txt = 'O(V + E)';
    case 2
        txt = 'O(V^2 + E)';
    case 3
        txt = 'O((V + E) log V)';
    otherwise
        txt = '-';
end
end

function txt = mem_path(pathNodes)
if isempty(pathNodes)
    txt = 'Path vector only';
else
    txt = sprintf('Path vector with %d node ids', numel(pathNodes));
end
end
