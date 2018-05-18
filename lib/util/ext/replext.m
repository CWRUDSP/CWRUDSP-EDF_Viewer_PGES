function file_path = replext(file_path, new_ext)
    new_ext(new_ext =='.') = [];
    file_path_base_name = dropext(file_path);
    file_path = sprintf('%s.%s',file_path_base_name, new_ext);
end
