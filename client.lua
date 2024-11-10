local hasPaid = false

local function spawnRiddlePed(
	modelHash,
	coords,
	scenario,
	riddleText,
	correctAnswer,
	imageUrl,
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

	local function handleInteraction()
		local header = "Riddle " .. riddleIndex - 1
		if correctAnswer == "" then
			local playerFunds = exports.ox_inventory:Search("count", "money")

			if not hasPaid then
				if Config.Price and Config.Price ~= false and playerFunds < Config.Price then
					lib.alertDialog({
						content = locale("price.not_enough"),
						centered = true,
					})
					return
				end

				if Config.Price and Config.Price ~= false then
					local confirmPayment = lib.alertDialog({
						header = locale("price.header"),
						content = locale("price.content", Config.Price),
						centered = true,
						cancel = true,
					})

					if confirmPayment == "confirm" then
						TriggerServerEvent("matti-riddles:removeMoney", Config.Price)
						Wait(10)
						hasPaid = true
					else
						return
					end
				end
			end

			lib.alertDialog({
				header = header,
				content = riddleText,
				centered = true,
			})
		else
			local userResponse =
				lib.inputDialog(header .. " answer", { { label = locale("input.give_answer"), type = "input" } })[1]

			if tostring(userResponse):lower() == correctAnswer:lower() then
				if riddleIndex == #Config.Riddles then
					lib.alertDialog({
						content = locale("input.completed"),
						centered = true,
					})
					TriggerServerEvent("matti-riddles:addRewards", Config.Rewards)
				else
					lib.alertDialog({
						header = locale("input.correct_answer"),
						content = riddleText .. " \n " .. " ![image](" .. imageUrl .. ")",
						centered = true,
					})
				end
			else
				lib.alertDialog({
					header = header,
					content = locale("input.wrong_answer"),
					color = "error",
					centered = true,
				})
				if Config.Debug then
					print("Answer to riddle " .. riddleIndex .. ": " .. correctAnswer)
				end
			end
		end
	end

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
		riddle.optionalPicture,
		riddle.optionalClothing,
		index
	)
end
