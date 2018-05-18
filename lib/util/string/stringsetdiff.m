function sdiff = stringsetdiff(A,B,charcmp)
    if nargin < 3
        charcmp = @strcmp;
    end

    sdiff = {};

    if isempty(A)
        b = true;
        return
    end

    in_B = cellfun(@(a) ~any(charcmp(a, B)), A);
    sdiff = A(in_B);

    in_A = cellfun(@(b) ~any(charcmp(b, A)), B);
    sdiff = cellflatten(sdiff, B(in_A));

    if isempty(A)
        sdiff = cellcast(B);
    elseif isempty(B)
        sdiff = cellcast(A);
    end
end

% if iscell(A)
%     if numel(A) ~= numel(B), return, end;

%     a_is_char = cellfun(@(a) ischar(a), A);
%     b_is_char = cellfun(@(b) ischar(b), B);

%     if ~all(a_is_char == b_is_char), return, end;

%     if ischar(A{1})
%         for i = 1:numel(A)
%             if ~any(charcmp(A{i},B)), return, end;
%         end
%     elseif isnumeric(A{1})
%         for i = 1:numel(A)
%             if ~any(A{i} == B), return, end;
%         end
%     else
%         error('What type is A{1}??');
%     end
% elseif isnumeric(A)
%     if ischar(A(1))
%         for i = 1:numel(A)
%             if ~any(charcmp(A(i),B)), return, end;
%         end
%     elseif isnumeric(A(1))
%         for i = 1:numel(A)
%             if ~any(A(i) == B), return, end;
%         end
%     else
%         error('What type is A(1)??');
%     end
% else
%     error('What type is A??');
% end
% b = true;
