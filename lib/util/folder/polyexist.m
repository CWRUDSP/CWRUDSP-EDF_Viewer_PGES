function res = polyexist(objs, objType)
    objs = cellcast(objs);
    res = cellfun(@(obj) exist(obj, objType), objs);
end
