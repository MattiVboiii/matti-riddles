local hasPaid = false
QBCore = exports["qb-core"]:GetCoreObject()
local unlockedRiddle = 0 -- tracks how many riddles the player has unlocked/completed

local function spawnRiddlePed(
	modelHash,
	coords,
	scenario,
	riddleText,
	correctAnswer,
	clothingOption,
	riddleIndex
)
	RequestModel(modelHash)
	while not HasModelLoaded(modelHash) do
		Wait(10)
	end

	local pedEntity = CreatePed(4, modelHash, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
	FreezeEntityPosition(pedEntity, true)
	SetEntityInvincible(pedEntity, true)
	SetBlockingOfNonTemporaryEvents(pedEntity, true)
	TaskStartScenarioInPlace(pedEntity, scenario, 0, true)
	SetModelAsNoLongerNeeded(modelHash)

	-- Apply optional skin by citizenid (simple behavior: clothingOption should be a citizenid string)
	if type(clothingOption) == "string" and clothingOption ~= "" then
		local citizenId = clothingOption
		local done, outfitData = false, nil
		QBCore.Functions.TriggerCallback("matti-riddles:getOutfit", function(result)
			outfitData = result
			done = true
		end, citizenId, tostring(modelHash))
		local waitCount = 0
		while not done and waitCount < 200 do
			Wait(10)
			waitCount = waitCount + 1
		end
		if outfitData then
			-- prefer full skin JSON
			local skinJson = outfitData.skin
			if type(skinJson) == "string" and skinJson:sub(1,1) == "{" then
				local ok, decoded = pcall(json.decode, skinJson)
				if ok and type(decoded) == "table" then
					if decoded.face then
						pcall(function() TriggerEvent("illenium-appearance:client:migration:load-qb-clothing-clothes", { skin = skinJson }, pedEntity) end)
					elseif exports["illenium-appearance"] and type(exports["illenium-appearance"].setPedAppearance) == "function" then
						pcall(function() exports["illenium-appearance"]:setPedAppearance(pedEntity, decoded) end)
					end
					goto skip_components
				end
			end
			-- fall back to components/props from player_outfits
			do
				local ok, decoded = pcall(json.decode, outfitData.components or "[]")
				if ok and type(decoded) == "table" then
					for _, c in ipairs(decoded) do
						if c.component_id and c.drawable then
							SetPedComponentVariation(pedEntity, tonumber(c.component_id), tonumber(c.drawable), tonumber(c.texture or 0), 0)
						end
					end
				end
				local ok2, props = pcall(json.decode, outfitData.props or "[]")
				if ok2 and type(props) == "table" then
					for _, p in ipairs(props) do
						if p.prop_id and (p.drawable or p.prop) then
							local drawable = tonumber(p.drawable or p.prop)
							SetPedPropIndex(pedEntity, tonumber(p.prop_id), drawable, tonumber(p.texture or 0), true)
						end
					end
				end
			end
			::skip_components::
		end
	end

	-- single-answer behavior: `correctAnswer` is expected to be a string

	local function levenshtein(a, b)
		if a == b then return 0 end
		local la, lb = #a, #b
		if la == 0 then return lb end
		if lb == 0 then return la end

		local row = {}
		for i = 0, lb do row[i] = i end
		for i = 1, la do
			local prev = row[0]
			row[0] = i
			for j = 1, lb do
				local cur = row[j]
				local cost = (a:sub(i,i) == b:sub(j,j)) and 0 or 1
				row[j] = math.min(row[j] + 1, row[j-1] + 1, prev + cost)
				prev = cur
			end
		end
		return row[lb]
	end

	local function isAlmostAnswer(input, answer)
		if not input or not answer then return false end
		local s = tostring(input):lower():gsub("%s+"," "):gsub("^%s*(.-)%s*$","%1")
		local t = tostring(answer):lower():gsub("%s+"," "):gsub("^%s*(.-)%s*$","%1")
		if s == "" or t == "" then return false end
		-- substring check (user typed most of the answer)
		if t:find(s, 1, true) or s:find(t, 1, true) then return true end
		local dist = levenshtein(s, t)
		local thresh = math.max(1, math.floor(#t * 0.3))
		return dist <= thresh
	end

	local function handleInteraction()
		local header = "Riddle " .. riddleIndex - 1

		-- Enforce sequential progression: player must have unlocked the previous riddle
		if riddleIndex > 1 and unlockedRiddle < (riddleIndex - 1) then
			lib.alertDialog({
				header = header,
				content = "You must complete the previous riddles first.",
				centered = true,
			})
			return
		end
		if correctAnswer == "" then
			if not hasPaid then
				if Config.Price and Config.Price ~= false then
					local hasEnough = nil
					QBCore.Functions.TriggerCallback("matti-riddles:hasEnoughMoney", function(result)
						hasEnough = result
					end, Config.Price, Config.PriceMethod)
					local waitCount = 0
					while hasEnough == nil and waitCount < 200 do
						Wait(10)
						waitCount = waitCount + 1
					end
					if not hasEnough then
						lib.alertDialog({
							content = locale("price.not_enough"),
							centered = true,
						})
						return
					end
					local confirmPayment = lib.alertDialog({
						header = locale("price.header"),
						content = locale("price.content", Config.Price),
						centered = true,
						cancel = true,
					})
					if confirmPayment == "confirm" then
						TriggerServerEvent("matti-riddles:removeMoney", Config.Price, Config.PriceMethod)
						Wait(10)
						hasPaid = true
					else
						return
					end
				end
			end
			local content = riddleText
			lib.alertDialog({
				header = header,
				content = content,
				centered = true,
			})
				-- Starting the riddle adventure unlocks riddle 1
				unlockedRiddle = math.max(unlockedRiddle, 1)
		else
			-- Gives input prompt for previous riddle answer
			local userResponse = lib.inputDialog(
				header .. " answer",
				{ { label = locale("input.give_answer", riddleIndex - 1), type = "input" } }
			)[1]
			-- Gets user answer and checks it with the right answer
			if tostring(userResponse):lower() == correctAnswer:lower() then
				-- If last riddle, it gives rewards
				if riddleIndex == #Config.Riddles then
					lib.alertDialog({
						content = locale("input.completed"),
						centered = true,
					})
					TriggerServerEvent("matti-riddles:addRewards", Config.Rewards)
				else
					-- Goes to next riddle
					local content = riddleText
					lib.alertDialog({
						header = locale("input.correct_answer"),
						content = content,
						centered = true,
					})
						-- mark this riddle as completed/unlocked
						unlockedRiddle = math.max(unlockedRiddle, riddleIndex)
				end
			else
				-- If answer is almost correct, give a friendly hint
				if isAlmostAnswer(userResponse, correctAnswer) then
					lib.alertDialog({
						header = header,
						content = locale("input.almost_answer") or "Almost! You're very close.",
						centered = true,
					})
				else
					-- If answer wrong, give wrong prompt
					lib.alertDialog({
						header = header,
						content = locale("input.wrong_answer"),
						centered = true,
					})
				end
				-- If debug is true, give answer in client console
				if Config.Debug then
					print("Answer to riddle " .. riddleIndex .. ": " .. correctAnswer)
				end
			end
		end
	end

	-- Target settings
	local interactionOptions = {
		{
			label = correctAnswer == "" and locale("riddle1.title") or ("Riddle " .. riddleIndex),
			onSelect = handleInteraction,
			icon = "fas fa-question",
			distance = 2.5,
		},
	}

	if Config.Target == "qb-target" then
		exports["qb-target"]:AddTargetEntity(pedEntity, { options = interactionOptions })
	elseif Config.Target == "ox_target" then
		exports.ox_target:addLocalEntity(pedEntity, interactionOptions)
	end
end

for index, riddle in pairs(Config.Riddles) do
	spawnRiddlePed(
		GetHashKey(riddle.model),
		riddle.coords,
		riddle.scenario,
		riddle.message,
		riddle.answer,
		riddle.optionalClothing,
		index
	)
end
