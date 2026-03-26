function list = build_key_linked_list(keyP)
%BUILD_KEY_LINKED_LIST Doubly-linked list over key points.

n = height(keyP);
list.head = 1;
list.tail = n;
list.length = n;
list.nodes = repmat(struct('lat', 0, 'lon', 0, 'name', "", 'next', 0, 'prev', 0), n, 1);

for i = 1:n
    list.nodes(i).lat = keyP.Latitude(i);
    list.nodes(i).lon = keyP.Longitude(i);
    list.nodes(i).name = string(keyP.Remark(i));
    list.nodes(i).prev = i - 1;
    list.nodes(i).next = i + 1;
end
list.nodes(1).prev = 0;
list.nodes(n).next = 0;
end
