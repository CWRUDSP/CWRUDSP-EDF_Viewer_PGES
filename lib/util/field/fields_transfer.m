function lhs = fields_transfer(lhs,rhs,ignores)
    % lhs = fields_transfer(lhs,rhs,ignore)
    if nargin < 3
        ignores = {};
    end

    fields = fieldnames(rhs);
    for i = 1:numel(fields)
        if ~any(cellfun(@(ignore) strcmp(ignore, fields{i}), ignores))
            lhs.(fields{i}) = rhs.(fields{i});
        end
    end
end
