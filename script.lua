--// =========================
--// SERVICES
--// =========================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

local potionLimit = 1


--// =========================
--// KNIT
--// =========================

local Knit = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit
local ShopService = Knit.Services.ShopService
local EventService = Knit.Services.EventService

local TeleportToShop = ShopService.RF.TeleportToShop
local TeleportToPlot = Knit.Services.PlotService.RF.TeleportToPlot

local GetAllCategoryStockRF = ShopService.RF.GetAllCategoryStock
local BuyItemRF = ShopService.RF.BuyItemFromCurrency

local ContributeRF = EventService.RF.ContributeToEvent
local GetTimeRemainingRF = EventService.RF.GetTimeRemaining


--// =========================
--// POSITIONS
--// =========================

local Positions = {
	Shop1 = Vector3.new(-395.85, 14.22, 177.90),
	Shop2 = Vector3.new(-389.90, 14.22, 25.10),
}


--// =========================
--// TELEPORT
--// =========================

local function TeleportTo(position)
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	root.CFrame = CFrame.new(position)
end


--// =========================
--// SAFE SERVER INVOKE
--// =========================

local function SafeInvoke(remote, ...)
	local success, result = pcall(function()
		return remote:InvokeServer(...)
	end)

	if success then
		return result
	end

	warn("Remote invoke failed:", remote.Name)
	return nil
end


--// =========================
--// BUY HANDLER
--// =========================

local function TryBuy(stockTable, categoryId, itemName, position, amount, printName)

	if not stockTable then return end

	for name, count in pairs(stockTable) do

		if name == itemName and count > 0 then

			TeleportTo(position)

			for i = 1, amount do
				BuyItemRF:InvokeServer(categoryId, itemName)
				print("[PURCHASED]", printName or itemName)
				task.wait(1)
			end

			break
		end
	end
end


--// =========================
--// MAIN SHOP LOOP
--// =========================

task.spawn(function()

	while true do

		local stock = SafeInvoke(GetAllCategoryStockRF)

		if stock then

			-- TimeBoost_Rare (Category 3)
			TryBuy(
				stock[3],
				3,
				"TimeBoost_Rare",
				Positions.Shop1,
				4,
				"TimeBoost_Rare"
			)


			-- Toadstool Tree (Category 2)
			TryBuy(
				stock[2],
				2,
				"Toadstool_Tree",
				Positions.Shop2,
				4,
				"Illustrious_Tree"
			)


			-- Bush Tile (Category 1)
			TryBuy(
				stock[1],
				1,
				"Bush_Tile",
				Positions.Shop2,
				3,
				"Bush_Tile"
			)

		end

		task.wait(10)
	end
end)


--// =========================
--// AUTO-CONTRIBUTE SYSTEM
--// =========================

local function GetTimePotions()

	local potions = {}

	for _, item in ipairs(backpack:GetChildren()) do

		if item:IsA("Tool") and item.Name == "Time Potion" then
			table.insert(potions, item)
		end

	end

	return potions
end


local function ContributePotions(potions)

	for _, item in ipairs(potions) do

		local inventoryId = item:GetAttribute("InventoryItemId")

		if inventoryId then

			ContributeRF:InvokeServer(1, inventoryId)
			print("Activated InventoryId:", inventoryId)

		else
			warn(item.Name, "missing InventoryItemId")
		end

		task.wait(1)
	end
end


--// =========================
--// AUTO-CONTRIBUTE LOOP
--// =========================

while true do

	local timeRemaining = SafeInvoke(GetTimeRemainingRF)

	if timeRemaining == 0 then

		local potions = GetTimePotions()

		if #potions >= potionLimit then
			ContributePotions(potions)
		end
	end

	task.wait(15)
end
