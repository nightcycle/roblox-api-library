--!strict
-- Services
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")
local option = require("@pkg/@nightcycle/option")
local vec = require("@pkg/@nightcycle/vec")
-- Modules
local src = require("../src")
-- Types
-- Constants
local UNIVERSE_ID = tonumber(luneUtil.Env["UNIVERSE_ID"]:expect(`UNIVERSE_ID is not set`))
assert(UNIVERSE_ID, "UNIVERSE_ID is not a number")
local DS_NAME = "test-standard-datastore"
local DS_KEY = "test-key"
local DS_VALUE = { a = 1, b = "b", c = true, d = { 1, 2, 3 }, f = { a = 1, b = 2, c = 3 } }
-- Variables
-- References
-- Private Functions
-- Class

print(
	`list datastores: {err.displayAsJson(
		src.apis.cloud.v1.universes.standardDatastores
			.get(UNIVERSE_ID, option.none(), option.none(), option.none())
			:await()
			:unwrap()
			:text()
			:unwrap()
	)}`
)

print(
	`got datastore keys: {err.displayAsJson(
		src.apis.cloud.v1.universes.standardDatastores.datastore.entries
			.get(UNIVERSE_ID, DS_NAME, option.none(), option.none(), option.none(), option.none(), option.none())
			:await()
			:unwrap()
			:text()
			:unwrap()
	)}`
)

print(
	`posted datastore entry: {err.displayAsJson(
		src.apis.cloud.v1.universes.standardDatastores.datastore.entries.entry
			.post(
				UNIVERSE_ID,
				DS_NAME,
				DS_KEY,
				DS_VALUE,
				option.none(),
				option.none(),
				option.none(),
				option.none(),
				option.some(vec.from({ 123 }))
			)
			:await()
			:unwrap()
			:text()
			:unwrap()
	)}`
)

print(
	`posted datastore entry: {err.displayAsJson(
		src.apis.cloud.v1.universes.standardDatastores.datastore.entries.entry
			.get(UNIVERSE_ID, DS_NAME, DS_KEY, option.none())
			:await()
			:unwrap()
			:text()
			:unwrap()
	)}`
)
