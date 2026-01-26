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
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

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

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoHarvestGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 190)
Frame.Position = UDim2.new(0.05, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

--// Draggable GUI
local dragging, dragStart, startPos

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

Frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--// Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Auto Farm"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Parent = Frame

--// Buttons
local function CreateButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 0, 35)
    btn.Position = UDim2.new(0.5, -80, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    btn.Text = text
    btn.TextScaled = true
    btn.Parent = Frame
    return btn
end

local HarvestButton = CreateButton("HARVEST: OFF", 40)
local AutoSellButton = CreateButton("AUTO SELL: OFF", 85)
local ManualSellButton = CreateButton("SELL NOW", 130)
ManualSellButton.BackgroundColor3 = Color3.fromRGB(100, 100, 220)

--// States
local HarvestEnabled = false
local AutoSellEnabled = false

--// Harvest Loop
local function HarvestLoop()
    while HarvestEnabled do
        local container = Workspace:WaitForChild("Scripted"):WaitForChild("PlantHarvestContainer")
        for _, plant in ipairs(container:GetChildren()) do
            if not HarvestEnabled then return end
            PlantServiceRF:InvokeServer(plant.Name)
        end

        if AutoSellEnabled then
            ShopServiceRF:InvokeServer()
        end

        task.wait(0.6)
    end
end

--// Harvest Toggle
HarvestButton.MouseButton1Click:Connect(function()
    HarvestEnabled = not HarvestEnabled

    if HarvestEnabled then
        HarvestButton.Text = "HARVEST: ON"
        HarvestButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
        task.spawn(HarvestLoop)
    else
        HarvestButton.Text = "HARVEST: OFF"
        HarvestButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    end
end)

--// Auto Sell Toggle (REQUIRES harvest OFF)
AutoSellButton.MouseButton1Click:Connect(function()
    if HarvestEnabled then
        AutoSellButton.Text = "TURN HARVEST OFF"
        task.delay(1.2, function()
            AutoSellButton.Text = AutoSellEnabled and "AUTO SELL: ON" or "AUTO SELL: OFF"
        end)
        return
    end

    AutoSellEnabled = not AutoSellEnabled

    if AutoSellEnabled then
        AutoSellButton.Text = "AUTO SELL: ON"
        AutoSellButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
    else
        AutoSellButton.Text = "AUTO SELL: OFF"
        AutoSellButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    end
end)

--// Manual Sell
ManualSellButton.MouseButton1Click:Connect(function()
    ShopServiceRF:InvokeServer()
end)
