function ics = isCellString(v)
    ics = false;
    if iscell(v)
        ics = ischar([v{:}]);
    end
end