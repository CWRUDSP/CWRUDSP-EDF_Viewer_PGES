function [files_list, folders_list] = findFiles(main_folder, sub_path, exts, recursive, include_dirs)
    %    [files_list, folders_list] = findFiles(main_folder=cd, sub_path='', ext='', recursive=true, include_dirs=true)
    %
    if nargin < 5
        include_dirs = true;
    end

    if nargin < 4
        recursive = true;
    end

    if nargin < 3
        exts = {''};
    end
    exts = cellflatten(exts);
    if numel(exts)==0
        exts = {''};
    end

    if nargin < 2
        sub_path = '';
    end

    if nargin < 1
        main_folder = pwd;
    end

    if isempty(main_folder)
        main_folder = cd;
    end

    dir_objects = get_dir_objects(main_folder, sub_path);

    files_list = {};
    folders_list = {};

    for i = 1:numel(dir_objects)
        is_dir = dir_objects(i).isdir;
        dir_name = dir_objects(i).name;

        if is_dir && recursive
            sub_dir_name = dir_name;

            if ~isempty(sub_path)
                sub_dir_name = joinpath(sub_path, dir_name);
            end

            [sub_files_list, sub_folder_list] = findFiles(main_folder, sub_dir_name, exts, recursive, include_dirs);

            files_list = {files_list{:}, sub_files_list{:}};
            folders_list = {folders_list{:}, sub_folder_list{:}};
        end

        could_have_exts = cellfun(@(ext) numel(dir_name) >= numel(ext), exts);
        if ~is_dir && (any(could_have_exts))% ||  (numel(exts)==1 && strcmpi(exts{1},'')))
            if sum(could_have_exts) > 0
                broken=false;
                for i=1:sum(could_have_exts)
                    if could_have_exts(i)
                        ext = exts(i);
                        [~,~,file_ext] = fileparts(dir_name);
                        if strcmpi(ext, file_ext)
                            files_list = {files_list{:}, dir_name}; % ok<*AGROW>
                            folders_list = {folders_list{:}, sub_path};
                            broken=true;
                            break
                        end
                    end
                end
            end
        end

        if is_dir && include_dirs
            files_list = {files_list{:}, ''}; %#ok<*AGROW>
            if any(sub_path)
                folders_list = {folders_list{:}, joinpath(sub_path, dir_name)};
            else
                folders_list = {folders_list{:}, dir_name};
            end
        end
    end

    if isempty(sub_path) && include_dirs
        files_list = {files_list{:}, ''}; %#ok<*AGROW>
        folders_list = {folders_list{:}, ''};
    end
end

function dir_objects = get_dir_objects(main_folder, sub_path)

    ignore = {'.','..'};

    dir_query = joinpath(main_folder,'*');

    if ~isempty(sub_path)
        dir_query =  joinpath(main_folder, sub_path, '*');
    end
    dir_objects = dir(dir_query);

    keep = arrayfun( @(dir_obj) ~any(strcmpi(dir_obj.name, ignore)), dir_objects);
    dir_objects = dir_objects(keep);
end

