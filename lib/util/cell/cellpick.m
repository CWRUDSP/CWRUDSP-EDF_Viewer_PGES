function [picked_items, picked_data] = cellpick(pick,items,picked)
	%	Reduces cell array by picking subset of items
	%
	%	arguments:
	%
	%		pick: true if want to pick.
	%		cell_array: true if want to pick.
	%		picked: (optional) func create some data on each item that will
	%			be also returned with the picked values.

	picked_data = {};
	picked_items = {};
	for i =1:numel(items);
		if pick(items{i})
			picked_items
			items
			picked_items = {picked_items{:}, items};
			if nargin == 3
				picked_data = {picked_data{:}, picked(items{i})};
			end
		end
	end
end
