function b = many(array)
    if iscell(array)
        b = numel(find([array{:}])) > 1;
    else
        b = numel(find(array)) > 1;
    end
end
