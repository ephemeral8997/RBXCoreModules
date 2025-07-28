local Dragger = {}
Dragger.IsDragging = false

function Dragger:Do(sources, targets)
    local dragStart, currentInput, startPositions, moved
    local MIN_DIST = 12

    local function reset()
        self.IsDragging = false
        dragStart, currentInput, moved = nil
    end

    local function clampToBounds(pos, size, boundary)
        local x = math.clamp(pos.X.Offset, 0, boundary.X - size.X)
        local y = math.clamp(pos.Y.Offset, 0, boundary.Y - size.Y)
        return UDim2.new(0, x, 0, y)
    end

    for _, source in ipairs(sources) do
        source.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragStart = input.Position
                currentInput = input
                moved = false
                startPositions = {}
                for _, t in ipairs(targets) do
                    startPositions[t] = t.Position
                end

                local oldCam = Camera.CameraType
                Camera.CameraType = Enum.CameraType.Scriptable

                local endedConn
                endedConn = Services.UserInputService.InputEnded:Connect(function(endInput)
                    if endInput == input then
                        if moved then
                            local final = targets[1].Position
                            for _, t in ipairs(targets) do
                                t.Position = final
                            end
                        end
                        Camera.CameraType = oldCam
                        reset()
                        endedConn:Disconnect()
                    end
                end)
            end
        end)
    end

    Services.UserInputService.InputChanged:Connect(function(input)
        if input == currentInput and dragStart then
            local delta = input.Position - dragStart
            if not moved and delta.Magnitude > MIN_DIST then
                moved, self.IsDragging = true, true
            end
            if self.IsDragging then
                local screenSize = targets[1].Parent.AbsoluteSize
                for _, t in ipairs(targets) do
                    local start = startPositions[t]
                    local desiredPos = start + UDim2.new(0, delta.X, 0, delta.Y)
                    t.Position = clampToBounds(desiredPos, t.AbsoluteSize, screenSize)
                end
            end
        end
    end)
end

return Dragger
