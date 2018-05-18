function file_names = path2name(file_paths)
    if iscell(file_paths)
        file_names = cellfun(@(file_path) {path2name(file_path)}, file_paths);
    else
        file_names = pathtoname_single(file_paths);
    end
end

function file_name = pathtoname_single(file_path)
    slash_pos = strfind(file_path, separator());
    file_name = file_path;
    if any(slash_pos)
        file_name = file_path(slash_pos(end)+1:end);
    end
end
