function b = checkIfIndecesAreValid(indeces, ui_indeces, selected_i, selected_i_ui)

    b = ~isempty(ui_indeces);
    b = b && any(ui_indeces == selected_i_ui);

    assert(isempty(indeces) == isempty(ui_indeces))
    assert(any(selected_i == indeces) == any(selected_i_ui == ui_indeces))

    if any(selected_i==indeces)
        assert(selected_i==indeces(find(ui_indeces == selected_i_ui,1)))
    end

