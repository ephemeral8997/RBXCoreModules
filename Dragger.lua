local Dragger = {}
Dragger.IsDragging = false

function Dragger:Do(sources, targets)
    local dragStart, currentInput, startPositions, moved
    local MIN_DIST = 12

    local function reset()
        self.IsDragging = false
        dragStart, currentInput, moved = nil
    end

    local function clampToBounds(pos, size, boundary, anchor)
        local absoluteX = pos.X.Offset - (anchor.X * size.X)
        local absoluteY = pos.Y.Offset - (anchor.Y * size.Y)

        local clampedX = math.clamp(absoluteX, 0, boundary.X - size.X)
        local clampedY = math.clamp(absoluteY, 0, boundary.Y - size.Y)

        return UDim2.new(0, clampedX + (anchor.X * size.X), 0, clampedY + (anchor.Y * size.Y))
    end

    for _, source in ipairs(sources) do
        source.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

                for _, t in ipairs(targets) do
                    if t.AbsolutePosition == Vector2.new(0, 0) then
                        t:GetPropertyChangedSignal("AbsolutePosition"):Wait()
                    end
                end

                startPositions = {}
                local dragOffsets = {}

                for _, t in ipairs(targets) do
                    startPositions[t] = t.Position
                    local absPos = t.AbsolutePosition
                    dragOffsets[t] = input.Position - absPos
                end

                dragStart = input.Position
                currentInput = input
                moved = false

                local oldCam = workspace.CurrentCamera.CameraType
                workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

                local endedConn
                endedConn = game:GetService("UserInputService").InputEnded:Connect(function(endInput)
                    if endInput == input then
                        if moved then
                            local finalPos = targets[1].Position
                            for _, t in ipairs(targets) do
                                t.Position = finalPos
                            end
                        end
                        workspace.CurrentCamera.CameraType = oldCam
                        reset()
                        endedConn:Disconnect()
                    end
                end)

                local movedConn
                movedConn = game:GetService("UserInputService").InputChanged:Connect(function(moveInput)
                    if moveInput == currentInput and dragStart then
                        local delta = moveInput.Position - dragStart
                        if not moved and delta.Magnitude > MIN_DIST then
                            moved, self.IsDragging = true, true
                        end
                        if self.IsDragging then
                            local screenSize = targets[1].Parent.AbsoluteSize
                            for _, t in ipairs(targets) do
                                local offset = dragOffsets[t]
    
                                local desiredAbsPos = moveInput.Position - offset
    
                                local parentPos = t.Parent.AbsolutePosition
                                local relativeX = desiredAbsPos.X - parentPos.X + (t.AnchorPoint.X * t.AbsoluteSize.X)
                                local relativeY = desiredAbsPos.Y - parentPos.Y + (t.AnchorPoint.Y * t.AbsoluteSize.Y)

                                local desiredPos = clampToBounds(
                                    UDim2.new(0, relativeX, 0, relativeY),
                                    t.AbsoluteSize,
                                    screenSize,
                                    t.AnchorPoint
                                )
                                t.Position = desiredPos
                            end
                        end
                    end
                end)

                        
                endedConn:Connect(function()
                    if movedConn then
                        movedConn:Disconnect()
                    end
                end)
            end
        end)
    end
end

return Dragger
