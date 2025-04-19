--!strict
-- Services
local fs = require("@lune/fs")
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")
local option = require("@pkg/@nightcycle/option")
local reqwest = require("@pkg/@nightcycle/reqwest")
-- Modules
local src = require("../src")
-- Types
-- Constants
local PLACE_ID = tonumber(luneUtil.Env["PLACE_ID"]:expect(`PLACE_ID is not set`))
local UNIVERSE_ID = tonumber(luneUtil.Env["UNIVERSE_ID"]:expect(`UNIVERSE_ID is not set`))
assert(PLACE_ID, "PLACE_ID is not a number")
assert(UNIVERSE_ID, "UNIVERSE_ID is not a number")
local PLACE_PATH = "tests/data/baseplate.rbxl"
-- Variables
-- References
local place = fs.readFile(PLACE_PATH)
-- Private Functions
-- Class
print(
	`saved place: {err.displayAsJson(
		src.apis.cloud.v1.universes.places.versions
			.post(UNIVERSE_ID, PLACE_ID, "Saved", place)
			:await()
			:unwrap()
			:json()
			:unwrap()
	)}`
)
print(
	`publish place: {err.displayAsJson(
		src.apis.cloud.v1.universes.places.versions
			.post(UNIVERSE_ID, PLACE_ID, "Published", place)
			:await()
			:unwrap()
			:json()
			:unwrap()
	)}`
)

do
	local intentionalError =
		src.apis.cloud.v1.universes.places.versions.post(UNIVERSE_ID, 1, "Saved", place):await():unwrapErr()
	print(`intentional error for bad place id: {err.displayAsJson(intentionalError:json():unwrap())}`)
	assert(
		intentionalError:status() == reqwest.Response.ERROR_CODES.BAD_REQUEST,
		`Expected status={reqwest.Response.ERROR_CODES.BAD_REQUEST}, received {intentionalError:status()}`
	)
end
do
	local intentionalError =
		src.apis.cloud.v1.universes.places.versions.post(1, PLACE_ID, "Saved", place):await():unwrapErr()
	print(`intentional error for bad universe id: {err.displayAsJson(intentionalError:json():unwrap())}`)
	assert(
		intentionalError:status() == reqwest.Response.ERROR_CODES.BAD_REQUEST,
		`Expected status={reqwest.Response.ERROR_CODES.BAD_REQUEST}, received {intentionalError:status()}`
	)
end
do
	local priorKey = luneUtil.Env["RBX_OPEN_CLOUD_API_KEY"]
	luneUtil.Env["RBX_OPEN_CLOUD_API_KEY"] = option.some("invalid-key")
	local intentionalError = src.apis.cloud.v1.universes.places.versions
		.post(UNIVERSE_ID, PLACE_ID, "Saved", place)
		:await()
		:unwrapErr()
	print(`intentional error for bad authorization: {err.displayAsJson(intentionalError:json():unwrap())}`)
	assert(
		intentionalError:status() == reqwest.Response.ERROR_CODES.UNAUTHORIZED,
		`Expected status={reqwest.Response.ERROR_CODES.UNAUTHORIZED}, received {intentionalError:status()}`
	)
	luneUtil.Env["RBX_OPEN_CLOUD_API_KEY"] = priorKey
end

for i = 1, 100 do
	local intentionalError =
		src.apis.cloud.v1.universes.places.versions.post(1, PLACE_ID, "Saved", place):await():unwrapErr()
	if intentionalError:status() == reqwest.Response.ERROR_CODES.TOO_MANY_REQUESTS then
		print(
			`intentional error on attempt #{i} for too-many-requests: {err.displayAsJson(
				intentionalError:json():unwrap()
			)}`
		)
		break
	elseif intentionalError:status() ~= reqwest.Response.ERROR_CODES.BAD_REQUEST then
		error(
			`Expected status={reqwest.Response.ERROR_CODES.BAD_REQUEST}, received {intentionalError:status()}`
		)
	end
end
