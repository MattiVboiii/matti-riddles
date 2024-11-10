-- //TODO See if mp_m_freemode_01 or mp_f_freemode_01 can spawn with clothing (from citizenid)
-- //TODO Add PriceMethod
-- //TODO Add multiple right answers support
-- //FIXME Add full compatibility with qb-inventory

Config = {}

Config.Debug = true -- When answer is wrong, right answer will be printed in the client console

-- Config.PriceMethod = "cash" -- "bank" or "cash" (COMING LATER, is cash/money for now)
Config.Price = 50 -- Price to begin the riddle adventure, can be set to false

Config.Riddles = {
	[1] = {
		model = "mp_m_freemode_01", -- Can be mp_m_freemode_01 (or mp_f_freemode_01) if you want optionalClothing to work (https://docs.fivem.net/docs/game-references/ped-models/)
		-- optionalClothing = "M808901N", -- Works only if model is mp_m_freemode_01 (or mp_f_freemode_01) (COMING LATER)
		scenario = "WORLD_HUMAN_STAND_IMPATIENT_UPRIGHT", -- The scenario the ped will be doing (https://github.com/DioneB/gtav-scenarios)
		coords = vec4(869.47, -1145.98, 24.2, 96.18), -- Coords where your ped will stand
		message = locale("riddle1.riddle"), -- The riddle message that can be set in the locales folder
		optionalPicture = "", -- EXPERIMENTAL, does not work sometimes (for me atleast), can be empty, will be included in the riddle message
		answer = locale("riddle1.answer"), -- The answer of the PREVIOUS riddle, can be set in the locales folder, should be empty for the first riddle
	},
	[2] = {
		model = "a_f_m_beach_01",
		scenario = "WORLD_HUMAN_STAND_MOBILE",
		coords = vec4(863.37, -1137.26, 23.88, 184.23),
		message = locale("riddle2.riddle"),
		optionalPicture = "https://i.imgur.com/vBTmzo9.jpeg",
		answer = locale("riddle2.answer"),
	},
	[3] = {
		model = "a_f_m_bodybuild_01",
		scenario = "WORLD_HUMAN_GARDENER_PLANT",
		coords = vec4(868.01, -1137.68, 23.91, 180.28),
		message = locale("riddle3.riddle"),
		optionalPicture = "https://i.imgur.com/vBTmzo9.jpeg",
		answer = locale("riddle3.answer"),
	},
	[4] = {
		model = "mp_f_cocaine_01",
		scenario = "WORLD_HUMAN_JOG_STANDING",
		coords = vec4(859.79, -1138.16, 23.94, 215.51),
		message = locale("riddle4.riddle"),
		optionalPicture = "https://i.imgur.com/vBTmzo9.jpeg",
		answer = locale("riddle4.answer"),
	},
}

Config.Rewards = { -- Will be given when completing last riddle
	[1] = {
		item = "tosti",
		amount = 10,
	},
	[2] = {
		item = "water_bottle",
		amount = 10,
	},
}

Config.Target = "ox_target" -- "qb-target" or "ox_target" (UNTESTED)
-- Config.Inventory = "ox_inventory" -- "qb-inventory" or "ox_inventory" (DOES NOT WORK COMPLETELY YET, is ox_inventory for now)
