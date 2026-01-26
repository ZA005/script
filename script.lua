-- local Players = game:GetService("Players")
-- local TeleportService = game:GetService("TeleportService")

-- local player = Players.LocalPlayer

-- -- Define teleport positions
-- local positions = {
--     Vector3.new(625, 1801, 3432.7),
--     Vector3.new(785.63, 2180.06, 3946.21),
-- }

-- -- Function to teleport character
-- local function teleportTo(pos)
--     local character = player.Character or player.CharacterAdded:Wait()
--     local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
--     humanoidRootPart.CFrame = CFrame.new(pos)
-- end

-- -- Run sequence
-- task.spawn(function()
--     -- Teleport to first position
--     teleportTo(positions[1])
--     task.wait(2)

--     -- Teleport to second position
--     teleportTo(positions[2])

-- end)
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// Remote Functions
local PlantServiceRF = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("PlantService")
    :WaitForChild("RF")
    :WaitForChild("ClaimHarvest")

local ShopServiceRF = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("ShopService")
    :WaitForChild("RF")
    :WaitForChild("SellAllHarvest")

--// GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoHarvestGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 140)  -- adjusted to fit two buttons
Frame.Position = UDim2.new(0, 20, 0, 20)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Auto-Harvest Toggle"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Parent = Frame

--// Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0.5, -60, 0.3, 0) -- higher to fit sell button
ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
ToggleButton.Text = "OFF"
ToggleButton.TextScaled = true
ToggleButton.Parent = Frame

--// Sell Button
local SellButton = Instance.new("TextButton")
SellButton.Size = UDim2.new(0, 120, 0, 40)
SellButton.Position = UDim2.new(0.5, -60, 0.7, -10) -- below toggle button
SellButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
SellButton.Text = "SELL"
SellButton.TextScaled = true
SellButton.Parent = Frame

--// Toggle state
local HarvestToggle = false

ToggleButton.MouseButton1Click:Connect(function()
    HarvestToggle = not HarvestToggle
    if HarvestToggle then
        ToggleButton.Text = "ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
    else
        ToggleButton.Text = "OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    end
end)

--// Harvest Function (no limit)
local function HarvestAll()
    local Container = Workspace:WaitForChild("Scripted"):WaitForChild("PlantHarvestContainer")
    local Plants = Container:GetChildren()
    
    for _, PlantData in ipairs(Plants) do
        local args = { PlantData.Name }
        PlantServiceRF:InvokeServer(unpack(args))
    end
end

--// Loop to run while toggle is ON
RunService.Heartbeat:Connect(function()
    if HarvestToggle then
        HarvestAll()
        wait(0.5)  -- small delay to avoid flooding server
    end
end)

--// Sell Button Function
SellButton.MouseButton1Click:Connect(function()
    ShopServiceRF:InvokeServer()
end)
