function [path, totalDist, stats] = dijkstra_heap(L, startNode, goalNode)
%DIJKSTRA_HEAP Dijkstra using a binary min-heap priority queue.

n = length(L);
dist = inf(1, n);
parent = zeros(1, n);
visited = false(1, n);
heap.keys = [];
heap.values = [];
stats.pushes = 0;
stats.pops = 0;
stats.relaxations = 0;

dist(startNode) = 0;
[heap, stats] = heap_push(heap, 0, startNode, stats);

while ~isempty(heap.keys)
    [heap, key, u, stats] = heap_pop(heap, stats);
    if visited(u)
        continue;
    end
    if key > dist(u)
        continue;
    end
    visited(u) = true;
    if u == goalNode
        break;
    end

    neighbors = L{u}(:,1);
    weights = L{u}(:,2);
    for i = 1:numel(neighbors)
        v = neighbors(i);
        alt = dist(u) + weights(i);
        stats.relaxations = stats.relaxations + 1;
        if ~visited(v) && alt < dist(v)
            dist(v) = alt;
            parent(v) = u;
            [heap, stats] = heap_push(heap, alt, v, stats);
        end
    end
end

if isinf(dist(goalNode))
    path = [];
    totalDist = inf;
    return;
end

path = goalNode;
while path(1) ~= startNode
    path = [parent(path(1)), path];
end
totalDist = dist(goalNode);
end

function [heap, stats] = heap_push(heap, key, value, stats)
heap.keys(end+1) = key;
heap.values(end+1) = value;
stats.pushes = stats.pushes + 1;
idx = numel(heap.keys);
while idx > 1
    p = floor(idx / 2);
    if heap.keys(p) <= heap.keys(idx)
        break;
    end
    [heap.keys(p), heap.keys(idx)] = deal(heap.keys(idx), heap.keys(p));
    [heap.values(p), heap.values(idx)] = deal(heap.values(idx), heap.values(p));
    idx = p;
end
end

function [heap, key, value, stats] = heap_pop(heap, stats)
key = heap.keys(1);
value = heap.values(1);
stats.pops = stats.pops + 1;
last = numel(heap.keys);
heap.keys(1) = heap.keys(last);
heap.values(1) = heap.values(last);
heap.keys(last) = [];
heap.values(last) = [];

idx = 1;
while true
    left = 2 * idx;
    right = left + 1;
    smallest = idx;
    if left <= numel(heap.keys) && heap.keys(left) < heap.keys(smallest)
        smallest = left;
    end
    if right <= numel(heap.keys) && heap.keys(right) < heap.keys(smallest)
        smallest = right;
    end
    if smallest == idx
        break;
    end
    [heap.keys(idx), heap.keys(smallest)] = deal(heap.keys(smallest), heap.keys(idx));
    [heap.values(idx), heap.values(smallest)] = deal(heap.values(smallest), heap.values(idx));
    idx = smallest;
end
end
