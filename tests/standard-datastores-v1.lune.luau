--!strict
-- Services
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")
local option = require("@pkg/@nightcycle/option")
local vec = require("@pkg/@nightcycle/vec")
-- Modules
local standardDatastores = require("../src/apis/cloud/v1/universes/standardDatastores")
local standardDatastoresDatastoreEntriesEntry =
	require("../src/apis/cloud/v1/universes/standardDatastores/datastore/entries/entry")
local standardDatastoresDatastoreEntriesEntryIncrement =
	require("../src/apis/cloud/v1/universes/standardDatastores/datastore/entries/entry/increment")
local standardDatastoresDatastoreEntries =
	require("../src/apis/cloud/v1/universes/standardDatastores/datastore/entries")
local standardDatastoresDatastoreEntriesEntryVersions =
	require("../src/apis/cloud/v1/universes/standardDatastores/datastore/entries/entry/versions")
local standardDatastoresDatastoreEntriesEntryVersionsVersion =
	require("../src/apis/cloud/v1/universes/standardDatastores/datastore/entries/entry/versions/version")

-- Types
-- Constants
local UNIVERSE_ID = tonumber(luneUtil.Env["UNIVERSE_ID"]:expect(`UNIVERSE_ID is not set`))
assert(UNIVERSE_ID, "UNIVERSE_ID is not a number")
local DS_NAME = "test-standard-datastore"
local DS_KEY = "test-key"
local DS_INC_KEY = "test-key-inc"
local DS_VALUE = { a = 1, b = "b", c = true, d = { 1, 2, 3 }, f = { a = 1, b = 2, c = 3 } }
-- Variables
-- References
-- Private Functions
-- Class

print(
	`list datastores: {err.displayAsJson(
		standardDatastores
			.get(UNIVERSE_ID, option.none(), option.none(), option.none())
			:await()
			:unwrap()
			:text()
			:unwrap()
	)}`
)

print(
	`got datastore keys: {err.displayAsJson(
		standardDatastoresDatastoreEntries
			.get(UNIVERSE_ID, DS_NAME, option.none(), option.none(), option.none(), option.none(), option.none())
			:await()
			:unwrap()
			:text()
			:unwrap()
	)}`
)

print(
	`posted datastore entry: {err.displayAsJson(
		standardDatastoresDatastoreEntriesEntry
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
	`posted datastore number entry: {err.displayAsJson(
		standardDatastoresDatastoreEntriesEntry
			.post(
				UNIVERSE_ID,
				DS_NAME,
				DS_INC_KEY,
				0,
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
	`got datastore entry: {err.displayAsJson(
		standardDatastoresDatastoreEntriesEntry
			.get(UNIVERSE_ID, DS_NAME, DS_KEY, option.none())
			:await()
			:unwrap()
			:text()
			:unwrap()
	)}`
)

print(
	`list datastore entry version: {err.displayAsJson(
		standardDatastoresDatastoreEntriesEntryVersions
			.get(
				UNIVERSE_ID,
				DS_NAME,
				DS_KEY,
				option.none(),
				option.none(),
				option.none(),
				option.none(),
				option.none(),
				option.none()
			)
			:await()
			:unwrap()
			:text()
			:unwrap()
	)}`
)

print(
	`got datastore entry version: {err.displayAsJson(
		standardDatastoresDatastoreEntriesEntryVersionsVersion
			.get(UNIVERSE_ID, DS_NAME, DS_KEY, "08DD7FC87F88736D.000000000E.08DD7FCA896E4834.01", option.none())
			:await()
			:unwrap()
			:text()
			:unwrap()
	)}`
)

print(
	`posted datastore increment entry: {err.displayAsJson(
		standardDatastoresDatastoreEntriesEntryIncrement
			.post(UNIVERSE_ID, DS_NAME, DS_INC_KEY, 1, option.none(), option.none(), option.none(), option.none())
			:await()
			:unwrap()
			:text()
			:unwrap()
	)}`
)

print(
	`deleted datastore increment entry: {err.displayAsJson(
		standardDatastoresDatastoreEntriesEntry
			.delete(UNIVERSE_ID, DS_NAME, DS_INC_KEY, option.none())
			:await()
			:unwrap()
			:text()
			:unwrap()
	)}`
)
