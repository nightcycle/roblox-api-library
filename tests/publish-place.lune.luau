--!strict
-- Services
local fs = require("@lune/fs")
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")
-- Modules
local placesVersions = require("../src/apis/cloud/v1/universes/places/versions")
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
		placesVersions.post(UNIVERSE_ID, PLACE_ID, "Saved", place):await():unwrap():json():unwrap()
	)}`
)
print(
	`publish place: {err.displayAsJson(
		placesVersions.post(UNIVERSE_ID, PLACE_ID, "Published", place):await():unwrap():json():unwrap()
	)}`
)
