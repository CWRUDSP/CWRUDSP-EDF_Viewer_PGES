function file_base_name = removeext(file_name)
    dot_pos = strfind(file_name,'.');
    file_base_name = file_name;
    if any(dot_pos)
        file_base_name = file_name(1:dot_pos(end)-1);
    end
end
