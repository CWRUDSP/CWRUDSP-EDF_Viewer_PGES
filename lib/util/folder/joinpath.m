function pth = joinpath(pth, varargin)
    for i = 1:numel(varargin)
        if ~isempty(varargin{i})
            if ~endswith(pth, separator())
                pth = [pth, separator(), varargin{i}];
            else
                pth = [pth, varargin{i}];
            end
        end
    end
end
