local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

-- Define teleport positions
local positions = {
    Vector3.new(625, 1801, 3432.7),
    Vector3.new(785.63, 2180.06, 3946.21),
}

-- Function to teleport character
local function teleportTo(pos)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(pos)
end

-- Run sequence
task.spawn(function()
    -- Teleport to first position
    teleportTo(positions[1])
    task.wait(2)

    -- Teleport to second position
    teleportTo(positions[2])
    task.wait(2)

end)
