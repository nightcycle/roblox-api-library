--!strict
-- Services
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")

-- Modules
local universes = require("../src/apis/cloud/v2/universes")
local universesPublishMessage = require("../src/apis/cloud/v2/universes/publishMessage")
local universesRestartServers = require("../src/apis/cloud/v2/universes/restartServers")

-- Types
-- Constants
local UNIVERSE_ID = tonumber(luneUtil.Env["UNIVERSE_ID"]:expect(`UNIVERSE_ID is not set`))
assert(UNIVERSE_ID, "UNIVERSE_ID is not a number")
local SKIP_RESTART = true
-- Variables
-- References
-- Private Functions
-- Class
print(`get universe: {err.displayAsJson(universes.get(UNIVERSE_ID):await():unwrap())}`)
print(`patch universe: {err.displayAsJson(universes
	.patch(UNIVERSE_ID, {
		mobileEnabled = false,
		robloxGroupSocialLink = {
			title = "group",
			uri = "https://www.roblox.com/groups/1234567",
			privateServerPriceRobux = 123,
		},
	})
	:await()
	:unwrap())}`)
print(
	`publish universe message: {err.displayAsJson(
		universesPublishMessage.post(UNIVERSE_ID, "test-topic", "test-message"):await():unwrap()
	)}`
)
if not SKIP_RESTART then
	print(`restart universe: {err.displayAsJson(universesRestartServers.post(UNIVERSE_ID):await():unwrap())}`)
end
