function dir_files = redir(folder)
    % dirs = redir(folder) - doesn't support * wildcards
    %
    % only returns dirs for files.
    %

    if nargin == 0
        folder=cd;
    end

    dir_files = redir_sub(folder, '');
end

function dir_files = redir_sub(top_folder, subfolder)


    % folder
    folder = [];
    if isempty(subfolder)
        folder = top_folder;
    else
        folder = joinpath(top_folder, subfolder);
    end

    dirs = dir(folder);

    is_folder = arrayfun(@(d) d.isdir && ~(strcmp(d.name, '.') || strcmp(d.name, '..') || strcmp(d.name, '.git')), dirs);
    is_file = arrayfun(@(d) ~d.isdir && ~(strcmp(d.name, '.') || strcmp(d.name, '..') || strcmp(d.name, '.git')), dirs);

    dir_files = dirs(is_file);
    dir_subfolders = dirs(is_folder);

    if numel(dir_files)>0
        for n = 1:numel(dir_files)
            dir_files(n).name = joinpath(subfolder, dir_files(n).name);
        end
    end
    
    for n = 1:numel(dir_subfolders)
        d = dir_subfolders(n);
        % pause(.1);

        sub_folder_arg = d.name;
        if ~isempty(subfolder)
            sub_folder_arg = joinpath(subfolder, sub_folder_arg);
        end

        dir_files_new = redir_sub(top_folder, sub_folder_arg);
        dir_files = [dir_files; dir_files_new];
    end
    
    
    
end
