function dispvec(description, vector)
    chunk_size = 10;
    chunks = round(numel(vector)/chunk_size);

    for i = 1:chunks
        a = 10*(i-1)+1;
        b = 10*i;
        if i == chunks
            b = numel(vector);
        end

        if i == 1
            fprintf('%s: \n\n\t%s\n\n', description, num2str(vector(a:b)));
        else
            fprintf('\t%s\n\n', num2str(vector(a:b)));
        end
    end

end
