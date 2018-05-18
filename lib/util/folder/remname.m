function [file_folder,is_default] = remname(filepath,folder_default)
    [file_folder,name,ext] = fileparts(filepath);
    is_default = nargin == 2 && isempty(file_folder);
    if is_default
        file_folder=folder_default;
    end
end
