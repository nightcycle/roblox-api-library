--!strict
-- Services
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")
local option = require("@pkg/@nightcycle/option")
-- Modules
local places = require("../src/apis/cloud/v2/universes/places")
-- Types
-- Constants
local PLACE_ID = tonumber(luneUtil.Env["PLACE_ID"]:expect(`PLACE_ID is not set`))
local UNIVERSE_ID = tonumber(luneUtil.Env["UNIVERSE_ID"]:expect(`UNIVERSE_ID is not set`))
assert(PLACE_ID, "PLACE_ID is not a number")
assert(UNIVERSE_ID, "UNIVERSE_ID is not a number")
-- Variables
-- References
-- Private Functions
-- Class
print(`get place: {err.displayAsJson(places.get(UNIVERSE_ID, PLACE_ID):await():unwrap())}`)
print(
	`set place: {err.displayAsJson(
		places
			.patch(
				UNIVERSE_ID,
				PLACE_ID,
				option.none(),
				option.some(`test desc: {luneUtil.Net.generateGUID(false)}`),
				option.some(1 + math.ceil((luneUtil.DateTime.now().unixTimestampMillis % 1000) / 10))
			)
			:await()
			:unwrap()
	)}`
)
