function j = getAlternateIndex(i, vec1, vec2)

    j = vec2(find(i == vec1,1));

    assert(any(i==vec1) == any(j==vec2))
end
