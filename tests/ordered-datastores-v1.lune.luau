--!strict
-- Services
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")
local option = require("@pkg/@nightcycle/option")
-- Modules
local orderedDatastoresScopesEntries =
	require("../src/apis/cloud/v1/universes/orderedDatastores/scopes/entries")
local orderedDatastoresScopesEntriesEntry =
	require("../src/apis/cloud/v1/universes/orderedDatastores/scopes/entries/entry")
local orderedDatastoresScopesEntriesEntryIncrement =
	require("../src/apis/cloud/v1/universes/orderedDatastores/scopes/entries/entry/increment")
-- Types
-- Constants
local UNIVERSE_ID = tonumber(luneUtil.Env["UNIVERSE_ID"]:expect(`UNIVERSE_ID is not set`))
assert(UNIVERSE_ID, "UNIVERSE_ID is not a number")
local DS_NAME = "test-ordered-datastore"
local DS_KEY = "test-key"
local DS_SCOPE = "test-scope"
-- Variables
-- References
-- Private Functions
-- Class

print(
	`list ordered-datastore keys: {err.displayAsJson(
		orderedDatastoresScopesEntries
			.get(
				UNIVERSE_ID,
				DS_NAME,
				DS_SCOPE,
				option.none(),
				option.none(),
				option.none(),
				option.none(),
				option.none()
			)
			:await()
			:unwrap()
	)}`
)

print(
	`posted ordered-datastore number entry: {err.displayAsJson(
		orderedDatastoresScopesEntries.post(UNIVERSE_ID, DS_NAME, DS_SCOPE, DS_KEY, 0):await():unwrap()
	)}`
)

print(
	`patched ordered-datastore number entry: {err.displayAsJson(
		orderedDatastoresScopesEntriesEntry.patch(UNIVERSE_ID, DS_NAME, DS_SCOPE, DS_KEY, 1):await():unwrap()
	)}`
)

print(
	`got ordered-datastore entry: {err.displayAsJson(
		orderedDatastoresScopesEntriesEntry.get(UNIVERSE_ID, DS_NAME, DS_SCOPE, DS_KEY):await():unwrap()
	)}`
)

print(
	`posted ordered-datastore increment entry: {err.displayAsJson(
		orderedDatastoresScopesEntriesEntryIncrement
			.post(UNIVERSE_ID, DS_NAME, DS_SCOPE, DS_KEY, 1)
			:await()
			:unwrap()
	)}`
)

print(
	`deleted ordered-datastore increment entry: {err.displayAsJson(
		orderedDatastoresScopesEntriesEntry.delete(UNIVERSE_ID, DS_NAME, DS_SCOPE, DS_KEY):await():unwrap()
	)}`
)
