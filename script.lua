-- Fly GUI + Draggable + Hold Jump Fly + Scrollable Teleport Dropdown + Get Position
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Auto-set WalkSpeed
humanoid.WalkSpeed = 20

-- Fly state
local flying = false
local flySpeed = 50
local bodyVelocity
local jumpHeld = false -- track jump button/space hold

-- Teleport positions
local teleportPositions = {
	Vector3.new(-173, 126, 406),
	Vector3.new(-153, 229, 648),
	Vector3.new(-40, 405, 608),
	Vector3.new(127, 652, 608),
	Vector3.new(238, 664, 736),
	Vector3.new(-682, 639, 874),
	Vector3.new(-659, 687, 1452),
	Vector3.new(-500, 902, 1865),
	Vector3.new(56, 947, 2083),
	Vector3.new(55, 980, 2458),
	Vector3.new(68, 1095, 2450),
	Vector3.new(245, 1268, 2034),
	Vector3.new(-407, 1304, 2389),
	Vector3.new(-769, 1312, 2657),
	Vector3.new(-837, 1473, 2636),
	Vector3.new(-464, 1466, 2760),
	Vector3.new(-417, 1740, 2795),
	Vector3.new(-415, 1712, 3430),
	Vector3.new(61, 1720, 3424),
	Vector3.new(635, 1796, 3426),
	Vector3.new(647.7, 1947.9, 3660), -- Summit
}

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame (panel)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 240)
frame.Position = UDim2.new(0.05, 0, 0.6, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Toggle button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Fly"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleBtn.Parent = frame

-- Get Position button
local getPosBtn = Instance.new("TextButton")
getPosBtn.Size = UDim2.new(1, -20, 0, 30)
getPosBtn.Position = UDim2.new(0, 10, 0, 60)
getPosBtn.Text = "Get Position"
getPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
getPosBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
getPosBtn.Parent = frame

-- Teleport dropdown button
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(1, -20, 0, 30)
teleportBtn.Position = UDim2.new(0, 10, 0, 100)
teleportBtn.Text = "Teleport ▼"
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
teleportBtn.Parent = frame

-- Scrollable dropdown container
local dropdownFrame = Instance.new("ScrollingFrame")
dropdownFrame.Size = UDim2.new(1, -20, 0, 100) -- visible height
dropdownFrame.Position = UDim2.new(0, 10, 0, 135)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dropdownFrame.ScrollBarThickness = 6
dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #teleportPositions * 28)
dropdownFrame.Visible = false
dropdownFrame.Parent = frame

-- UIListLayout for stacking buttons
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 3)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = dropdownFrame

-- Create teleport buttons
for i, pos in ipairs(teleportPositions) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 25)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	btn.Text = (i == #teleportPositions) and "Summit" or ("POS " .. i)
	btn.Parent = dropdownFrame

	btn.MouseButton1Click:Connect(function()
		character:MoveTo(pos)
		dropdownFrame.Visible = false
	end)
end

-- Toggle dropdown
teleportBtn.MouseButton1Click:Connect(function()
	dropdownFrame.Visible = not dropdownFrame.Visible
end)

-- Fly functions
local function startFlying()
	if flying then return end
	flying = true
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new(0,0,0)
	bodyVelocity.MaxForce = Vector3.new(4000,4000,4000)
	bodyVelocity.Parent = humanoidRootPart
	toggleBtn.Text = "Stop Flying"
	toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
end

local function stopFlying()
	flying = false
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end
	toggleBtn.Text = "Fly"
	toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
end

-- Toggle button
toggleBtn.MouseButton1Click:Connect(function()
	if flying then
		stopFlying()
	else
		startFlying()
	end
end)

-- Get Position handler
getPosBtn.MouseButton1Click:Connect(function()
	local pos = humanoidRootPart.Position
	print("Current Position: " .. tostring(pos))
end)

-- Detect jump hold (PC + Mobile)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Space then
		jumpHeld = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Space then
		jumpHeld = false
	end
end)

-- Mobile jump listener
local function setupJumpListener()
	local touchGui = player:WaitForChild("PlayerGui"):WaitForChild("TouchGui", 10)
	if touchGui then
		local jumpButton = touchGui:FindFirstChild("JumpButton", true)
		if jumpButton then
			jumpButton.InputBegan:Connect(function()
				jumpHeld = true
			end)
			jumpButton.InputEnded:Connect(function()
				jumpHeld = false
			end)
		end
	end
end
if UserInputService.TouchEnabled then
	setupJumpListener()
end

-- Movement
RunService.RenderStepped:Connect(function()
	if flying and bodyVelocity then
		local moveDirection = Vector3.new()

		-- PC
		if not UserInputService.TouchEnabled then
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				moveDirection += workspace.CurrentCamera.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				moveDirection -= workspace.CurrentCamera.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				moveDirection -= workspace.CurrentCamera.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				moveDirection += workspace.CurrentCamera.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				moveDirection -= Vector3.new(0,1,0)
			end
		else
			-- Mobile Joystick
			if humanoid.MoveDirection.Magnitude > 0 then
				moveDirection += humanoid.MoveDirection
			end
		end

		-- Hold Space / Jump to fly upward
		if jumpHeld then
			moveDirection += Vector3.new(0,1,0)
		end

		if moveDirection.Magnitude > 0 then
			bodyVelocity.Velocity = moveDirection.Unit * flySpeed
		else
			bodyVelocity.Velocity = Vector3.new(0,0,0)
		end
	end
end)
