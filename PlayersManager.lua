PlayerOpsCore = {
    GetServerPlayersByFuzzyPrefix = function(prefix: string): { Player }
        --[[
            Returns all players currently in the server
            whose username or display name matches the prefix, fuzzy-matched.
        ]]
        for _, player in ipairs(Services.Players:GetPlayers()) do
        end
    end,
}

return PlayerOpsCore
