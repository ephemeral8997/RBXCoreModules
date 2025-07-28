-- SelfOpsCore: LocalPlayer actions & control
-- LocalPlayer is defined elsewhere — play like it is.
local SelfOpsCore = {
    -- Instantly moves LocalPlayer to a world position
    TeleportTo = function(self, position: Vector3)
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character:PivotTo(CFrame.new(position))
        else
            dev_log(2, "Teleport failed: Character or HRP missing.")
        end
    end,

    -- Moves LocalPlayer to another player's position
    TeleportToPlayer = function(self, player: Player)
        local targetChar = player and player.Character
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            self:TeleportTo(targetChar.HumanoidRootPart.Position)
        else
            dev_log(2, "Teleport failed: Target player or HRP missing.")
        end
    end,

    -- Forces LocalPlayer to reset their character
    ResetCharacter = function(self)
        local character = LocalPlayer.Character
        if character then
            character:BreakJoints()
        else
            dev_log(2, "Reset failed: Character not found.")
        end
    end,

    -- Plays a one-off animation on LocalPlayer's humanoid
    PlayAnimation = function(self, animId: string, speed: number?)
        local character = LocalPlayer.Character
        if not character then
            dev_log(2, "Animation failed: Character not found.")
            return
        end

        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then
            dev_log(2, "Animation failed: Humanoid not found.")
            return
        end

        local animator = humanoid:FindFirstChildWhichIsA("Animator")
        if not animator then
            dev_log(2, "Animation failed: Animator not found.")
            return
        end

        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. animId

        local track = animator:LoadAnimation(animation)
        if speed then
            track:AdjustSpeed(speed)
        end
        track:Play()
    end,
}

return SelfOpsCore
