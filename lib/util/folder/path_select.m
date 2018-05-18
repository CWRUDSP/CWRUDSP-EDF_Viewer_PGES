function paths = path_select(paths, new_path)

    found_logic = strcmpi(paths, new_path);
    if ~any(found_logic)
        %add directory
        ind = 1:numel(found_logic);
        found_ind = ind(found_logic);
        found_ind = found_ind(1);

        if found_ind == 2
            return
        elseif found_ind < numel(paths)
            paths = {paths{1}, paths{found_ind}, paths{2:found_ind-1}, paths{found_ind+1:end}};
        else
            paths = {paths{1}, paths{found_ind}, paths{2:end-1}};
        end
    else
        paths = {paths{1}, new_path, paths{2:end}};
    end
end
