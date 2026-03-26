function [node, idx, steps] = list_find_key_by_name(list, name)
%LIST_FIND_KEY_BY_NAME Linear O(n) lookup over linked list.

current = list.head;
steps = 0;
while current ~= 0
    steps = steps + 1;
    if strcmpi(list.nodes(current).name, string(name))
        node = list.nodes(current);
        idx = current;
        return;
    end
    current = list.nodes(current).next;
end
error('Key point "%s" was not found in linked list.', string(name));
end
