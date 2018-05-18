function file_name = rmfilepath(file_path)
    file_name = file_path;
    sep_pos = strfind(file_path,separator());
    if any(sep_pos)
        file_name = file_path(sep_pos(end)+1:end);
    end
end
