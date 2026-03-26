function rows = format_benchmark_table(bench)
rows = {
    'Linked-list lookup', sprintf('%.4f', bench.listMs), 'O(n)'
    'KD-tree nearest lookup', sprintf('%.4f', bench.kdMs), 'Average O(log n), worst O(n)'
    'BFS path search', sprintf('%.4f', bench.bfsMs), 'O(V + E)'
    'Dijkstra (normal)', sprintf('%.4f', bench.dijkstraMs), 'O(V^2 + E) with linear min search'
    'Dijkstra (priority queue)', sprintf('%.4f', bench.dijkstraPQMs), 'O((V + E) log V)'
    };
end
