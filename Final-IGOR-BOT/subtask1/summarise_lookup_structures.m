function txt = summarise_lookup_structures(ctx)
%SUMMARISE_LOOKUP_STRUCTURES Return readable summary for the UI.
listNames = strings(1, ctx.linkedList.length);
cur = ctx.linkedList.head;
i = 1;
while cur ~= 0 && i <= ctx.linkedList.length
    listNames(i) = string(ctx.linkedList.nodes(cur).name);
    cur = ctx.linkedList.nodes(cur).next;
    i = i + 1;
end
listNames = listNames(listNames ~= "");

[kdNames, kdDepth] = kd_preorder_names(ctx.kdTree, 1, strings(0,1), 0);
if isempty(kdNames)
    kdRoot = "(empty)";
else
    kdRoot = kdNames(1);
end

parts = {
    sprintf('Linked list built: yes')
    sprintf('  Nodes: %d', ctx.linkedList.length)
    sprintf('  Head -> Tail: %s', strjoin(cellstr(listNames), ' -> '))
    sprintf('  Lookup method: linear scan across all nodes')
    sprintf('  Complexity: O(n)')
    ' '
    sprintf('KD-tree built: yes')
    sprintf('  Root node: %s', kdRoot)
    sprintf('  Tree depth: %d', kdDepth)
    sprintf('  Traversal preview: %s', strjoin(cellstr(kdNames(:)'), ' | '))
    sprintf('  Lookup method: spatial nearest-neighbour search')
    sprintf('  Complexity: average O(log n), worst O(n)')
    ' '
    sprintf('Both structures are built from the key-point table (%d key points).', ctx.nodes.nKey)
    'Nearest-key queries in this UI run both methods and compare their live timings.'
    };

txt = strjoin(parts, sprintf('\n'));
end

function [names, maxDepth] = kd_preorder_names(node, depth, names, maxDepth)
if isempty(node)
    return;
end
names(end+1,1) = string(node.name);
maxDepth = max(maxDepth, depth);
[names, maxDepth] = kd_preorder_names(node.left, depth+1, names, maxDepth);
[names, maxDepth] = kd_preorder_names(node.right, depth+1, names, maxDepth);
end
