function bench = benchmark_subtask1(ctx, repeats)
%BENCHMARK_SUBTASK1 Empirical benchmarking for Subtask 1.
if nargin < 2
    repeats = 100;
end

keyNames = string(ctx.keyP.Remark);
numKeys = numel(keyNames);
keyCoords = [ctx.keyP.Latitude, ctx.keyP.Longitude];

tList = zeros(repeats, 1);
tKD = zeros(repeats, 1);
tBFS = zeros(repeats, 1);
tDij = zeros(repeats, 1);
tPQ = zeros(repeats, 1);

for i = 1:repeats
    idx = mod(i-1, numKeys) + 1;
    jdx = mod(i+2, ctx.nodes.nTotal) + 1;
    tic; list_find_key_by_name(ctx.linkedList, keyNames(idx)); tList(i) = toc;
    tic; kd_k_nearest_keys(ctx.kdTree, keyCoords(idx,1), keyCoords(idx,2), 1); tKD(i) = toc;
    tic; bfsShortestPath(ctx.graph, idx, jdx); tBFS(i) = toc;
    tic; dijkstraShortestPath(ctx.graph, idx, jdx); tDij(i) = toc;
    tic; dijkstra_heap(ctx.graph, idx, jdx); tPQ(i) = toc;
end

bench.listMs = mean(tList) * 1000;
bench.kdMs = mean(tKD) * 1000;
bench.bfsMs = mean(tBFS) * 1000;
bench.dijkstraMs = mean(tDij) * 1000;
bench.dijkstraPQMs = mean(tPQ) * 1000;
end
