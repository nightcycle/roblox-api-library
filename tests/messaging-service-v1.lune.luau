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
local UNIVERSE_ID = tonumber(luneUtil.Env["UNIVERSE_ID"]:expect(`UNIVERSE_ID is not set`))
assert(UNIVERSE_ID, "UNIVERSE_ID is not a number")
local TOPIC = "test-topic"
local MESSAGE = "test-message"
local ATTEMPT_TO_HIT_RATE_LIMIT = false
-- Variables
-- References
-- Private Functions
-- Class
print(
	`sent message: {err.displayAsJson(
		src.apis.cloud.v1.messagingService.post(UNIVERSE_ID, TOPIC, MESSAGE):await():unwrap():text():unwrap()
	)}`
)
do
	local intentionalError = src.apis.cloud.v1.messagingService.post(1, TOPIC, MESSAGE):await():unwrapErr()
	print(`intentional error for bad universe id: {err.displayAsJson(intentionalError:json():unwrap())}`)
	assert(
		intentionalError:status() == reqwest.Response.ERROR_CODES.FORBIDDEN,
		`Expected status={reqwest.Response.ERROR_CODES.FORBIDDEN}, received {intentionalError:status()}`
	)
end
do
	local intentionalError =
		src.apis.cloud.v1.messagingService.post(UNIVERSE_ID, TOPIC, string.rep(`_`, 1025)):await():unwrapErr()
	print(`intentional error for too-large message: {err.displayAsJson(intentionalError:json():unwrap())}`)
	assert(
		intentionalError:status() == reqwest.Response.ERROR_CODES.BAD_REQUEST,
		`Expected status={reqwest.Response.ERROR_CODES.BAD_REQUEST}, received {intentionalError:status()}`
	)
end
do
	local priorKey = luneUtil.Env["RBX_OPEN_CLOUD_API_KEY"]
	luneUtil.Env["RBX_OPEN_CLOUD_API_KEY"] = option.some("invalid-key")
	local intentionalError =
		src.apis.cloud.v1.messagingService.post(UNIVERSE_ID, TOPIC, MESSAGE):await():unwrapErr()
	print(`intentional error for bad authorization: {err.displayAsJson(intentionalError:json():unwrap())}`)
	assert(
		intentionalError:status() == reqwest.Response.ERROR_CODES.UNAUTHORIZED,
		`Expected status={reqwest.Response.ERROR_CODES.UNAUTHORIZED}, received {intentionalError:status()}`
	)
	luneUtil.Env["RBX_OPEN_CLOUD_API_KEY"] = priorKey
end

-- it is very high, might not be worth it
if ATTEMPT_TO_HIT_RATE_LIMIT then
	local hitRateLimit = false
	for i = 1, 1000 do
		local intentionalError =
			src.apis.cloud.v1.messagingService.post(1, TOPIC, MESSAGE):await():unwrapErr()
		if intentionalError:status() == reqwest.Response.ERROR_CODES.TOO_MANY_REQUESTS then
			hitRateLimit = true
			print(
				`intentional error on attempt #{i} for too-many-requests: {err.displayAsJson(
					intentionalError:json():unwrap()
				)}`
			)
			break
		elseif intentionalError:status() ~= reqwest.Response.ERROR_CODES.FORBIDDEN then
			error(
				`Expected status={reqwest.Response.ERROR_CODES.FORBIDDEN}, received {intentionalError:status()}`
			)
		end
	end
	if not hitRateLimit then
		error(`Expected to hit rate limit, but did not`)
	end
end
