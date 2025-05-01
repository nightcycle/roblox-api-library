--!strict
-- Services
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")
-- Modules
local messagingService = require("../src/apis/cloud/v1/universes/messagingService")
-- Types
-- Constants
local UNIVERSE_ID = tonumber(luneUtil.Env["UNIVERSE_ID"]:expect(`UNIVERSE_ID is not set`))
assert(UNIVERSE_ID, "UNIVERSE_ID is not a number")
local TOPIC = "test-topic"
local MESSAGE = "test-message"
-- Variables
-- References
-- Private Functions
-- Class
print(
	`sent message: {err.displayAsJson(
		messagingService.post(UNIVERSE_ID, TOPIC, MESSAGE):await():unwrap():text():unwrap()
	)}`
)
