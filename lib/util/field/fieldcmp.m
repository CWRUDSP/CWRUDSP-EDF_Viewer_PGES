function [fields_both, fields_a_unique, fields_b_unique] = fieldcmp(a,b)

    fields_a = {};
    fields_a_unique = {};

    fields_b = {};
    fields_b_unique = {};

    fields_both = {};

    if isstruct(a)
        fields_a = fieldnames(a);
        fields_a_is_field_b = ones(1,numel(fields_a));
        for i = 1:numel(fields_a)
            f = fields_a{i};
            fields_a_is_field_b(i) = isfield(b,f);
        end

        fields_a_is_field_b = logical(fields_a_is_field_b);
        fields_a_unique = fields_a(~fields_a_is_field_b);
        fields_both = fields_a(fields_a_is_field_b);
    end

    if isstruct(b)
        fields_b = fieldnames(b);
        fields_b_is_field_a = zeros(1,numel(fields_b));
        for i = 1:numel(fields_b)
            f = fields_b{i};
            fields_b_is_field_a(i) = isfield(a,f);
        end

        fields_b_is_field_a = logical(fields_b_is_field_a);
        fields_b_unique = fields_b(~fields_b_is_field_a);
    end
end
