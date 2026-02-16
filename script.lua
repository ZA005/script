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

local TeleportToShop = ShopService.RF.TeleportToShop
local TeleportToPlot = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PlotService.RF.TeleportToPlot
local GetAllCategoryStockRF = ShopService.RF.GetAllCategoryStock
local BuyItemRF = ShopService.RF.BuyItemFromCurrency

--// =========================
--// EVENT
--// =========================
local EventService = Knit.Services.EventService
local ContributeRF = EventService.RF.ContributeToEvent
local GetTimeRemainingRF = EventService.RF.GetTimeRemaining


--// =========================
--// Coordinates
--// =========================

local positions = {
    Vector3.new(-395.85, 14.22, 177.90),
    Vector3.new(-389.90, 14.22, 25.10),
}

local function teleportTo(pos)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoidRootPart.CFrame = CFrame.new(pos)
end

--// =========================
--// Main Loop
--// =========================

task.spawn(function()
    while true do
        local success, stock = pcall(function()
            return GetAllCategoryStockRF:InvokeServer()
        end)

        if success and stock then
            -- Loop 1: TimeBoost_Rare
            for itemName, amount in pairs(stock[3]) do
                if itemName == "TimeBoost_Rare" and amount > 0 then
                    teleportTo(positions[1])

                    for i = 1, 4 do
                        BuyItemRF:InvokeServer(3, "TimeBoost_Rare")
                        print("[PURCHASED] TimeBoost_Rare")
                        task.wait(1)
                    end

                    -- TeleportToPlot:InvokeServer()
                end

                -- if itemName == "CloudBoost_Legendary" and amount > 0 then
                --     teleportTo(positions[1])

                --     for i = 1, 4 do
                --         BuyItemRF:InvokeServer(3, "CloudBoost_Legendary")
                --         print("[PURCHASED] CloudBoost_Legendary")
                --         task.wait(1)
                --     end

                --     -- TeleportToPlot:InvokeServer()
                -- end
            end
			
            for itemName, amount in pairs(stock[2]) do
                if itemName == "Palm_Tree" and amount > 0 then
                    teleportTo(positions[2])

                    for i = 1, 4 do
                        BuyItemRF:InvokeServer(2, "Palm_Tree")
                        print("[PURCHASED] Palm_Tree")
                        task.wait(1)
                    end

                    -- TeleportToPlot:InvokeServer()
                end
            end

            -- Loop 2: Tiles
            for itemName, amount in pairs(stock[1]) do

			    if itemName == "Valentine_Tile" and amount > 0 then
			        teleportTo(positions[2])
			
			        for i = 1, 3 do
			            BuyItemRF:InvokeServer(1, "Valentine_Tile")
			            print("[PURCHASED] Valentine_Tile")
			            task.wait(1)
			        end
			
			    elseif itemName == "Bush_Tile" and amount > 0 then
			        teleportTo(positions[2])
			
			        for i = 1, 3 do
			            BuyItemRF:InvokeServer(1, "Bush_Tile")
			            print("[PURCHASED] Bush_Tile")
			            task.wait(1)
			        end
			
			    elseif (
			        itemName == "Moss"
			        or itemName == "Meadow"
			        or itemName == "Enchanted_Grass"
			        or itemName == "Terra_Preta_Soil"
			        or itemName == "Rare_Soil"
			        or itemName == "Fresh_Grass"
			    ) and amount > 0 then
			
			        teleportTo(positions[2])
			
			        for i = 1, 3 do
			            BuyItemRF:InvokeServer(1, "Moss")
						BuyItemRF:InvokeServer(1, "Enchanted_Grass")
						BuyItemRF:InvokeServer(1, "Terra_Preta_Soil")
						BuyItemRF:InvokeServer(1, "Rare_Soil")
						BuyItemRF:InvokeServer(1, "Meadow")
						BuyItemRF:InvokeServer(1, "Fresh_Grass")
			            task.wait(1)
			        end
			
			    end
			end
        end
        -- print("[LOOP REFRESH]")
        task.wait(10) -- Wait 10 seconds before repeating
    end
end)


--// =========================
--// AUTO-CONTRIBUTE SURGE
--// =========================

-- Gather all Time Potions in backpack
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
