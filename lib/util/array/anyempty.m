function b = anyempty(val, possibleVals)
    b = false;
    empty = isempty(possibleVals);
    if ~empty
        % val
        % possibleVals
        b = any(val==possibleVals);
    end
end
