function K = strfindi(TEXT,PATTERN)
    % strfind Find one string within another, ignoring case.
    %     K = strfindi(TEXT,PATTERN) returns the starting indices of any
    %     occurrences of the string PATTERN in the string TEXT, ignoring case.
    %
    %     strfind will always return [] if PATTERN is longer than TEXT.
    %
    %     Examples
    %         s = 'How much wood would a woodchuck chuck?';
    %         strfind(s,'a')    returns  21
    %         strfind('a',s)    returns  []
    %         strfind(s,'wood') returns  [10 23]
    %         strfind(s,'Wood') returns  []
    %         strfind(s,' ')    returns  [4 9 14 20 22 32]
    %
    %     See also strcmpi, strncmp, regexp.
    K = strfind(lower(TEXT),lower(PATTERN));
end



