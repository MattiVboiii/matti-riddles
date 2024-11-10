QBCore = exports["qb-core"]:GetCoreObject()

RegisterServerEvent("matti-riddles:removeMoney")
AddEventHandler("matti-riddles:removeMoney", function(price)
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	player.Functions.RemoveMoney("cash", price)
end)

RegisterServerEvent("matti-riddles:addRewards")
AddEventHandler("matti-riddles:addRewards", function(rewards)
	local src = source
	if Config.Inventory == "qb-inventory" then
		for _, reward in ipairs(rewards) do
			local Player = QBCore.Functions:GetPlayer(src)
			Player.Functions.AddItem(reward.item, reward.amount)
		end
	elseif Config.Inventory == "ox_inventory" then
		for _, reward in ipairs(rewards) do
			exports.ox_inventory:AddItem(src, reward.item, reward.amount)
		end
	end
end)

-- Register an event to set the ped's clothing
--[[ RegisterServerEvent("matti-riddles:setPedClothing")
AddEventHandler("matti-riddles:setPedClothing", function(model, citizenId)
	-- Get the clothing data for the citizen
	local query = "SELECT * FROM player_outfits WHERE citizenid = @citizenId"
	local result = MySQL.query.await(query, { ["@citizenId"] = citizenId })

	-- Set the ped's clothing
	if result[1] then
		local components = json.decode(result[1].components)

		-- Set the clothing components
		for _, component in ipairs(components) do
			SetPedComponentVariation(ped, component.component_id, component.drawable, component.texture, 0)
		end
	end
end) ]]

-- Version checker
PerformHttpRequest(
	"https://raw.githubusercontent.com/MattiVboiii/matti-riddles/main/VERSION",
	function(Error, OnlineVersion, Header)
		OfflineVersion = LoadResourceFile("matti-riddles", "VERSION")
		if Error ~= 200 then
			error("^3 [ERROR]: There was an error, it is: HTTP" .. Error)
			return 0
		else
			if OnlineVersion == OfflineVersion then
				print("^3 [LATEST]: ^2 You are running the latest version of this script.")
			end
			if OnlineVersion > OfflineVersion then
				print("^3 [UPDATE]: ^1 There is a new version of this script available!")
				print("^3 [UPDATE]: ^7 Check out on Github: https://github.com/MattiVboiii/matti-riddles")
			end
			if OnlineVersion < OfflineVersion then
				print(
					"^3 [FUTURE??]: ^1 Are you living in the future? Because this version of the script has not been released yet..."
				)
			end
		end
	end
)
