function [ files_list ] = get_folder_files(folder_fullpath,extension)
    files_list = {};
    %process extension arg
    if nargin < 2
       extension = '.*';
    end
    
    if numel(extension) > 0
        if ~strcmpi(extension(1),'.')
            extension = ['.', extension];
        end
    else
       extension = '.*';
    end

    % if folder doesn't exist, return empty
    try 
        IS_FOLDER = 7;
        if exist(folder_fullpath,'dir') ~= IS_FOLDER
            return
        end
    catch
        return
    end
    
    ignore = {'.','..'};
    dir_query = [folder_fullpath, separator(), '*', extension];
    folder_items = dir(dir_query);

    for i = 1:numel(folder_items)
        if ~folder_items(i).isdir
            if ~any(strcmpi(folder_items(i).name, ignore))
                files_list = [files_list, folder_items(i).name ];%#ok<AGROW>
            end
        end
    end
    files_list = sort(files_list)
end