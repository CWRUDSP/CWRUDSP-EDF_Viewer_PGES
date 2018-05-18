function [index, item_found] = pickfirst(pick,items)
    if iscell(items)
        items = items{:};
    end

    item_found = true;
	for i = 1:numel(items)
		if pick(items(i))
            index = i;
            return
		end
    end

    index = -1;
    item_found = false;
end
