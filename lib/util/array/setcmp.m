function b = setcmp(A,B,charcmp)
    if nargin < 3
        charcmp = @strcmp;
    end

    b = false;

    if ~all(ischar(A) == ischar(B)), return, end;
    if ~all(iscell(A) == iscell(B)), return, end;
    if ~all(isempty(A) == isempty(B)), return, end;
    if ~all(isscalar(A) == isscalar(B)), return, end;
    if ~all(isnumeric(A) == isnumeric(B)), return, end ;

    if isempty(A)
        b = true;
        return
    end

    if iscell(A)

        if numel(A) ~= numel(B), return, end;

        a_is_char = reshape(cellfun(@(a) ischar(a), A),1,[]);
        b_is_char = reshape(cellfun(@(b) ischar(b), B),1,[]);

        if ~all(a_is_char == b_is_char), return, end;

        if ischar(A{1})
            for i = 1:numel(A)
                if ~any(charcmp(A{i},B)), return, end;
            end
        elseif isnumeric(A{1})
            for i = 1:numel(A)
                if ~any(A{i} == B), return, end;
            end
        else
            error('What type is A{1}??');
        end
    elseif isnumeric(A)
        if ischar(A(1))
            for i = 1:numel(A)
                if ~any(charcmp(A(i),B)), return, end;
            end
        elseif isnumeric(A(1))
            for i = 1:numel(A)
                if ~any(A(i) == B), return, end;
            end
        else
            error('What type is A(1)??');
        end
    else
        error('What type is A??');
    end
    b = true;
end
