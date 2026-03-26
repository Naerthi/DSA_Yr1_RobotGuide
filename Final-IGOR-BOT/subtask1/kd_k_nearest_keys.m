function result = kd_k_nearest_keys(tree, refLat, refLon, k)
%KD_K_NEAREST_KEYS k nearest neighbours from KD-tree.
query = [refLon, refLat];
best.items = repmat(struct('index', 0, 'name', "", 'lat', 0, 'lon', 0, 'distance', inf), max(k,1), 1);
best.count = 0;
best.visited = 0;
best = kd_search_recursive(tree, query, k, best);
result = best.items(1:best.count);
[~, order] = sort([result.distance]);
result = result(order);
end

function best = kd_search_recursive(node, query, k, best)
if isempty(node)
    return;
end
best.visited = best.visited + 1;

d = latlonDistanceMeters(query(2), query(1), node.lat, node.lon);
candidate = struct('index', node.index, 'name', node.name, 'lat', node.lat, 'lon', node.lon, 'distance', d);
best = insert_candidate(best, candidate, k);

axisId = node.axis;
qVal = query(axisId);
nodeVal = [node.lon, node.lat];
nodeVal = nodeVal(axisId);

if qVal < nodeVal
    nearBranch = node.left;
    farBranch = node.right;
else
    nearBranch = node.right;
    farBranch = node.left;
end

best = kd_search_recursive(nearBranch, query, k, best);

approxAxisMeters = abs(qVal - nodeVal) * 111320;
worst = worst_distance(best);
if best.count < k || approxAxisMeters < worst
    best = kd_search_recursive(farBranch, query, k, best);
end
end

function best = insert_candidate(best, candidate, k)
if best.count < k
    best.count = best.count + 1;
    best.items(best.count) = candidate;
else
    [maxDist, idx] = max([best.items(1:k).distance]);
    if candidate.distance < maxDist
        best.items(idx) = candidate;
    end
end
end

function d = worst_distance(best)
if best.count == 0
    d = inf;
else
    d = max([best.items(1:best.count).distance]);
end
end
