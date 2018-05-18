function lengths = string_lengths(strings)
    lengths = zeros(1,numel(strings));
    for i = 1:numel(lengths)
        lengths(i) = numel(strings{i});
    end
end