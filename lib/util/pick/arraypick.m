function values = arraypick(values, pick_func)
    pick = arrayfun(@(val) pick_func(val), values);
    values = values(pick);
end
