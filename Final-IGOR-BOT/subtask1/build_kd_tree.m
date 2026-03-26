function tree = build_kd_tree(keyP)
%BUILD_KD_TREE Balanced 2D KD-tree over key points.
pts = [keyP.Longitude, keyP.Latitude];
names = string(keyP.Remark);
idx = (1:height(keyP))';
tree = kd_build_recursive(pts, names, idx, 1);
end

function node = kd_build_recursive(pts, names, idx, depth)
if isempty(idx)
    node = [];
    return;
end
axisId = mod(depth-1, 2) + 1;
[~, order] = sort(pts(idx, axisId));
sortedIdx = idx(order);
mid = ceil(numel(sortedIdx) / 2);
rootIdx = sortedIdx(mid);
node.index = rootIdx;
node.name = names(rootIdx);
node.lon = pts(rootIdx, 1);
node.lat = pts(rootIdx, 2);
node.axis = axisId;
node.left = kd_build_recursive(pts, names, sortedIdx(1:mid-1), depth+1);
node.right = kd_build_recursive(pts, names, sortedIdx(mid+1:end), depth+1);
end
