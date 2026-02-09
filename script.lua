local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack") 
local potionLimit = 1

local Knit = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit
local ShopService = Knit.Services.ShopService

local TeleportToPlot = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PlotService.RF.TeleportToPlot
local GetAllCategoryStockRF = ShopService.RF.GetAllCategoryStock
local BuyItemRF = ShopService.RF.BuyItemFromCurrency

local EventService = Knit.Services.EventService
local ContributeRF = EventService.RF.ContributeToEvent
local GetTimeRemainingRF = EventService.RF.GetTimeRemaining

local function teleportTo(pos)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(pos)
end

print("LOADED SUCCESSFULLY")
task.spawn(function()
    while true do
        local success, stock = pcall(function()
            return GetAllCategoryStockRF:InvokeServer()
        end)

        if success and stock then
            -- Loop 1: TimeBoost_Rare
            for itemName, amount in pairs(stock[3]) do
                if itemName == "TimeBoost_Rare" and amount > 0 then

                    for i = 1, 4 do
                        BuyItemRF:InvokeServer(3, "TimeBoost_Rare")
                        print("[PURCHASED] TimeBoost_Rare")
                        task.wait(1)
                    end
                end
            end
        end
        task.wait(10) -- Wait 10 seconds before repeating
    end
end)

while true do  

	-- Get remaining event time
	local timeRemaining = GetTimeRemainingRF:InvokeServer()

	-- Only run if time is 0
	if timeRemaining == 0 then

		local timePotions = {}

		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") and item.Name == "Time Potion" then
				table.insert(timePotions, item)
			end
		end

		-- Total quantity
		local quantity = #timePotions

		-- Check if quantity meets requirement
		if quantity >= potionLimit then

			for _, item in ipairs(timePotions) do

				local inventoryId = item:GetAttribute("InventoryItemId")

				if inventoryId then

					ContributeRF:InvokeServer(1, inventoryId)

					print("Activated InventoryId:", inventoryId)

				else
					warn(item.Name, "is missing InventoryItemId")
				end

				-- Wait before next item
				task.wait(1)
			end
		end
	end

	-- Loop delay
	task.wait(15)
end
