function [props_both, props_a_unique, props_b_unique] = haspropcmp(a,b)

    props_a = {};
    props_b = {};
    props_both = {};
    props_a_unique = {};
    props_b_unique = {};


    if has_propnames(a)
        props_a = fieldnames(a);

        props_a_is_prop_b = ones(1,numel(props_a));
        for i = 1:numel(props_a)
            f = props_a{i};
            props_a_is_prop_b(i) = isprop(b,f);
        end

        props_a_is_prop_b = logical(props_a_is_prop_b);
        props_a_unique = props_a(~props_a_is_prop_b);
        props_both = props_a(props_a_is_prop_b);
    end

    if has_propnames(b)
        props_b = fieldnames(b);
        props_b_is_prop_a = zeros(1,numel(props_b));
        for i = 1:numel(props_b)
            f = props_b{i};
            props_b_is_prop_a(i) = isprop(a,f);
        end

        props_b_is_prop_a = logical(props_b_is_prop_a);
        props_b_unique = props_b(~props_b_is_prop_a);
    end
end

function has = has_propnames(s)
    has = true
    try
        fieldnames(s);
    catch
        has = false;
    end
end
