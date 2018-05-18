function b = one(array)
    if iscell(array)
        b = numel(find([array{:}])) == 1;
    else
        b = numel(find(array));
    end
end
