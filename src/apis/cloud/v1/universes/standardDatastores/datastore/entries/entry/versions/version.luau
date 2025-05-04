--!strict
-- Packages
local result = require("@pkg/@nightcycle/result")
local option = require("@pkg/@nightcycle/option")
local future = require("@pkg/@nightcycle/future")
local reqwest = require("@pkg/@nightcycle/reqwest")

-- Modules
local client = require("../../../../../../../../../client")

-- Constants
local CONSTANTS = require("../../../../../../../../../CONSTANTS")

-- Types
type Result<V, E> = result.Result<V, E>
type Option<V> = option.Option<V>
type Future<V> = future.Future<V>
type Response<B> = reqwest.Response<B>
type DataStoreEntryValue =
	boolean
	| number
	| string
	| { DataStoreEntryValue }
	| { [string]: DataStoreEntryValue }
-- Private Functions

-- Class
local Util = {}

-- lists the datastores
function Util.get(
	universeId: number,
	datastoreName: string,
	entryKey: string,
	versionId: string,
	scope: Option<string>
): Future<Result<DataStoreEntryValue, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL
						.. `/datastores/v1/universes/{universeId}/standard-datastores/datastore/entries/entry/versions/version`,
					{
						datastoreName = datastoreName,
						entryKey = entryKey,
						scope = scope:unwrapOr("global"),
						versionId = versionId,
					}
				)
			)
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(ok)
				return result.ok(ok:json():unwrap())
			end, function(eResponse)
				return result.err(eResponse)
			end)
	end)
end

return Util
