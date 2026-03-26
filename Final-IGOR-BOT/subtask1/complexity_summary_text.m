function txt = complexity_summary_text()
lines = {
    'Theory summary:'
    '  Linked list exact lookup: O(n) time, O(n) memory'
    '  KD-tree nearest lookup: average O(log n), worst O(n)'
    '  BFS on adjacency list: O(V + E)'
    '  Dijkstra without PQ: O(V^2 + E) due to linear extract-min'
    '  Dijkstra with binary heap PQ: O((V + E) log V)'
    '  Adjacency-list graph memory: O(V + E)'
    '  Occupancy grid memory from Task 1 map: O(nm)'
    ' '
    'For this UI:'
    '  - Linked list is used for exact key-point lookup and full linear scans.'
    '  - KD-tree is used for nearest and k-nearest key-point queries.'
    '  - BFS / Dijkstra / Dijkstra+PQ are available for route queries.'
    };
txt = sprintf('%s\n', lines{:});
end
