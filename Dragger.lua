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

    for _, frame in ipairs(frames) do -- ✅ Fix 1: ipairs
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragStart, currentInput, moved, activeFrame = input.Position, input, false, frame
                startPositions = {}
                for _, f in ipairs(frames) do -- ✅ Fix 1 repeated
                    startPositions[f] = f.Position
                end

                local oldCam = Camera.CameraType
                Camera.CameraType = Enum.CameraType.Scriptable

                -- ✅ Fix 2: add fallback to InputEnded
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
                        endedConn:Disconnect() -- cleanup
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
                for _, f in ipairs(frames) do
                    local start = startPositions[f]
                    f.Position = start + UDim2.new(0, delta.X, 0, delta.Y)
                end
            end
        end
    end)
end

return Dragger
