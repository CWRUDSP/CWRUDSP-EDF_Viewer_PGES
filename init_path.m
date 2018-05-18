%--------------------------------------------------------------------------
% @license
% Copyright 2018 IDAC Signals Team, Case Western Reserve University 
%
% Lincensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public 
% you may not use this file except in compliance with the License.
%
% Unless otherwise separately undertaken by the Licensor, to the extent possible, 
% the Licensor offers the Licensed Material as-is and as-available, and makes no representations 
% or warranties of any kind concerning the Licensed Material, whether express, implied, statutory, or other. 
% This includes, without limitation, warranties of title, merchantability, fitness for a particular purpose, 
% non-infringement, absence of latent or other defects, accuracy, or the presence or absence of errors, 
% whether or not known or discoverable. 
% Where disclaimers of warranties are not allowed in full or in part, this disclaimer may not apply to You.
%
% To the extent possible, in no event will the Licensor be liable to You on any legal theory 
% (including, without limitation, negligence) or otherwise for any direct, special, indirect, incidental, 
% consequential, punitive, exemplary, or other losses, costs, expenses, or damages arising out of 
% this Public License or use of the Licensed Material, even if the Licensor has been advised of 
% the possibility of such losses, costs, expenses, or damages. 
% Where a limitation of liability is not allowed in full or in part, this limitation may not apply to You.
%
% The disclaimer of warranties and limitation of liability provided above shall be interpreted in a manner that, 
% to the extent possible, most closely approximates an absolute disclaimer and waiver of all liability.
%
% Developed by the IDAC Signals Team at Case Western Reserve University 
% with support from the National Institute of Neurological Disorders and Stroke (NINDS) 
%     under Grant NIH/NINDS U01-NS090405 and NIH/NINDS U01-NS090408.
%              James McDonald
%--------------------------------------------------------------------------
function subfolders = init_path(varargin)
    fclose('all');
    disp('Clearing old path...')
    eval('restoredefaultpath')%in eval string to prevent compiled versiion from giving warning.

    top_folders = {'lib'};
    project_folder = pwd;
    subfolders = {project_folder};
    for i = 1:numel(top_folders)
        top_subfolder = joinpath(project_folder, top_folders{i});
        local_subfolders = get_subfolders(top_subfolder);
        subfolders = {subfolders{:}, top_subfolder, local_subfolders{:}};
        fprintf('Adding ~/%s/... to matlab path...\n', top_folders{i});
    end
    addpath(subfolders{:});
    %
    %   Add java jar paths
    %
    jar_path=joinpath(cd,'src','jars');
    javaaddpath(jar_path);
    subfolders = subfolders';
end


function subfolders = get_subfolders(addfolder, ignore_folders, ignore_prefixes)

    if nargin < 3
        ignore_prefixes = {};
    end

    if nargin < 2
        ignore_folders = {};
    end

    if nargin < 1
        addfolder = cd;
    end

    subfolders = {};
    objects = dir(addfolder);
    ignore = unique([ {'.'}, {'..'}, ignore_folders{:} ]);
    ignore_prefixes = unique([ {'+'}, ignore_prefixes(:) ]);

    mycellfun = @(fun, varargin) logical(cellfun(fun,varargin{:}));

    for i = 1:numel(objects)
        include = true;
        for j = 1:numel(ignore)

            if any(strfind(objects(i).name,ignore{j}))
                include = false;
                break;
            end
            prefix_is_long_enough = @(prefix) numel(objects(i).name) <= numel(prefix);
            same_prefix = @(prefix) strcmp(objects(i).name(1:numel(prefix)),prefix);

            prefixes_long_enough = mycellfun(prefix_is_long_enough, ignore_prefixes);
            folder_prefix_found = mycellfun(same_prefix, ignore_prefixes(~prefixes_long_enough));

            if any(folder_prefix_found)
                include = false;
                break;
            end
        end

        if ~include
            continue
        end

        if objects(i).isdir
            subfolder = [addfolder, sep, objects(i).name];

            % addpath(subfolder); % include the path
            subfolders = {subfolders{:}, subfolder}; %#ok<CCAT>

            more_subfolders = {};
            if ~any(strfind(addfolder,'opensource'))
                more_subfolders = get_subfolders(subfolder, {}, {'+'});
            end
            subfolders = {subfolders{:}, more_subfolders{:}}; %#ok<CCAT>
        end
    end
end

function se = sep()
    se = '\';
    if ~ispc
        se = '/';
    end
end

function pth = joinpath(pth,varargin)
    for i = 1:numel(varargin)
        if ~isempty(varargin{i})
            pth = [pth, sep(), varargin{i}]; %#ok<AGROW>
        end
    end
end
