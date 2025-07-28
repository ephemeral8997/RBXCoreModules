local Dragger = {}
Dragger.IsDragging = false

function Dragger:Do(...)
    local frames = { ... }
    local dragStart, currentInput, startPositions, moved, activeFrame
    local MIN_DIST = 12

    local function reset()
        self.IsDragging = false
        dragStart, currentInput, moved, activeFrame = nil
    end

    local function clampToBounds(pos, size, boundary)
        return UDim2.new(
            0, math.clamp(pos.X, 0, boundary.X - size.X),
            0, math.clamp(pos.Y, 0, boundary.Y - size.Y)
        )
    end

    for _, frame in ipairs(frames) do
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragStart, currentInput, moved, activeFrame = input.Position, input, false, frame
                startPositions = {}
                for _, f in ipairs(frames) do
                    startPositions[f] = f.Position
                end

                local oldCam = Camera.CameraType
                Camera.CameraType = Enum.CameraType.Scriptable

                local endedConn
                endedConn = Services.UserInputService.InputEnded:Connect(function(endInput)
                    if endInput == input then
                        if moved and activeFrame then
                            local pos = activeFrame.Position
                            for _, f in ipairs(frames) do
                                f.Position = pos
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
            if self.IsDragging and activeFrame then
                local screenSize = activeFrame.Parent.AbsoluteSize
                for _, f in ipairs(frames) do
                    local start = startPositions[f]
                    local desiredPos = start + UDim2.new(0, delta.X, 0, delta.Y)
                    f.Position = clampToBounds(desiredPos, f.AbsoluteSize, screenSize)
                end
            end
        end
    end)
end

return Dragger
