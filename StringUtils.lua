local StringMatchUtils = {}

-- Levenshtein Distance
function StringMatchUtils.Levenshtein(s1: string, s2: string): number
    s1, s2 = s1:lower(), s2:lower()
    local len1, len2 = #s1, #s2
    local matrix = {}

    for i = 0, len1 do
        matrix[i] = {}
        matrix[i][0] = i
    end

    for j = 0, len2 do
        matrix[0][j] = j
    end

    for i = 1, len1 do
        for j = 1, len2 do
            local cost = s1:sub(i, i) == s2:sub(j, j) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i - 1][j] + 1,
                matrix[i][j - 1] + 1,
                matrix[i - 1][j - 1] + cost
            )
        end
    end

    return matrix[len1][len2]
end

-- Fuzzy prefix match
function StringMatchUtils.IsFuzzyPrefixMatch(input: string, target: string, threshold: number): boolean
    input, target = input:lower(), target:lower()
    if #input > #target then return false end

    local targetPrefix = target:sub(1, #input)
    local distance = StringMatchUtils.Levenshtein(input, targetPrefix)
    return distance <= threshold
end

return StringMatchUtils
