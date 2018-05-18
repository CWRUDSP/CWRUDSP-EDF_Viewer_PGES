function [both_empty, a_empty, b_empty, neither_empty] = emptypropcmp(a,b)
    %   [both_empty, a_empty, b_empty, neither_empty] = emptypropcmp(a,b)
    %   
    %   a = instance with properties
    %   b = different instance with properties
    %   
    %   note: isfield(a,property) will return false,
    %       as the isfield appears to only work for structs
    %       and not object instances with properties.
    %
    %
    
    [both_fields, ~, ~] = haspropcmp(a,b);

    neither_empty = {}.';
    both_empty = {}.';
    a_empty = {}.';
    b_empty = {}.';

    for i = 1:numel(both_fields)
        f = both_fields{i};
        if isempty(a.(f)) && isempty(b.(f))
            both_empty = {both_empty{:}, f};
        elseif isempty(a.(f))
            a_empty = {a_empty{:}, f};
        elseif isempty(b.(f))
            b_empty = {b_empty{:}, f};
        else
            neither_empty = {neither_empty{:},f};
        end
    end
end

function has = has_propnames(s)
    has = true;
    try
        fieldnames(s);
    catch
        has = false;
    end
end
