lib.versionCheck("MattiVboiii/matti-riddles")

QBCore = exports["qb-core"]:GetCoreObject()

RegisterServerEvent("matti-riddles:removeMoney")
AddEventHandler("matti-riddles:removeMoney", function(price, method)
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	local m = method or Config.PriceMethod or "cash"
	if m == "bank" then
		player.Functions.RemoveMoney("bank", price)
	else
		player.Functions.RemoveMoney("cash", price)
	end
end)

QBCore.Functions.CreateCallback("matti-riddles:hasEnoughMoney", function(source, cb, price, method)
	local player = QBCore.Functions.GetPlayer(source)
	local m = method or Config.PriceMethod or "cash"
	local funds = 0
	if player and player.PlayerData and player.PlayerData.money then
		if m == "bank" then
			funds = player.PlayerData.money['bank'] or 0
		else
			funds = player.PlayerData.money['cash'] or 0
		end
	end
	cb(funds >= (price or 0))
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

-- Callback to get an outfit row by citizenid (and optional model)
QBCore.Functions.CreateCallback("matti-riddles:getOutfit", function(source, cb, citizenid, model)
	if not citizenid or citizenid == "" then
		cb(nil)
		return
	end
	-- Prefer full skin from illenium-appearance playerskins table when available
	local skin = nil
	if model and model ~= "" then
		skin = MySQL.scalar.await("SELECT skin FROM playerskins WHERE citizenid = ? AND model = ? LIMIT 1", {citizenid, model})
	end
	if not skin then
		skin = MySQL.scalar.await("SELECT skin FROM playerskins WHERE citizenid = ? AND active = 1 LIMIT 1", {citizenid})
	end
	if skin and type(skin) == "string" and skin:sub(1,1) == "{" then
		cb({ skin = skin })
		return
	end

	-- Otherwise fall back to player_outfits table (components/props)
	local result = nil
	if model and model ~= "" then
		result = MySQL.query.await("SELECT * FROM player_outfits WHERE citizenid = ? AND model = ? LIMIT 1", {citizenid, model})
		if result and #result > 0 then
			cb(result[1])
			return
		end
	end
	result = MySQL.query.await("SELECT * FROM player_outfits WHERE citizenid = ? LIMIT 1", {citizenid})
	if result and #result > 0 then
		cb(result[1])
	else
		cb(nil)
	end
end)

-- (Removed legacy server event: matti-riddles:setPedClothing)
