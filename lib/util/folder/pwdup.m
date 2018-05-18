function pth = pwdup(folderCount)
    if nargin < 1
        pth = pwd;
        return
    elseif folderCount <= 0
        pth = pwd;
        return
    end
        
    pth = pwd;

    if ~ispc
        %TODO: 
        assert(0,'Handle paths for mac macs.')
    end

    slash_indeces = strfind(pth,'\');
    slash_index = slash_indeces(end);
    if folderCount >= numel(slash_indeces)
        folderCount = numel(slash_indeces);
        slash_index = slash_indeces(numel(slash_indeces)-folderCount+1)+1;
    else        
        folderCount = min(numel(slash_indeces)-1,folderCount);
        slash_index = slash_indeces(numel(slash_indeces)-folderCount+1);
    end

    pth = pth(1:(slash_index-1));
end