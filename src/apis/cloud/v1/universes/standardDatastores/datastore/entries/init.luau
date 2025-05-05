--!strict
-- Packages
local result = require("@pkg/@nightcycle/result")
local option = require("@pkg/@nightcycle/option")
local future = require("@pkg/@nightcycle/future")
local hashMap = require("@pkg/@nightcycle/hash-map")
local vec = require("@pkg/@nightcycle/vec")
local vecDeque = require("@pkg/@nightcycle/vec-deque")
local err = require("@pkg/@nightcycle/error")
local reqwest = require("@pkg/@nightcycle/reqwest")
local luneUtil = require("@pkg/@nightcycle/lune-util")

-- Modules
local client = require("../../../../../../../client")

-- Constants
local CONSTANTS = require("../../../../../../../CONSTANTS")

-- Types
type Result<V, E> = result.Result<V, E>
type Option<V> = option.Option<V>
type Future<V> = future.Future<V>
type HashMap<K, V> = hashMap.HashMap<K, V>
type MutHashMap<K, V> = hashMap.MutHashMap<K, V>
type Vec<V> = vec.Vec<V>
type MutVec<V> = vec.MutVec<V>
type VecDeque<V> = vecDeque.VecDeque<V>
type Error<V, B> = err.Error<V, B>
type Response<B> = reqwest.Response<B>
type CompatDateTime = luneUtil.CompatDateTime
type DataStoreEntryValue =
	boolean
	| number
	| string
	| { DataStoreEntryValue }
	| { [string]: DataStoreEntryValue }
-- Private Functions

-- Class
local Util = {}
Util.entry = require("./entry")

-- lists the entries
function Util.get(
	universeId: number,
	datastoreName: string,
	allScopes: Option<boolean>,
	scope: Option<string>,
	cursor: Option<string>,
	limit: Option<number>,
	prefix: Option<string>
): Future<Result<{
	keys: { { key: string } },
	nextPageCursor: Option<string>,
}, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL
						.. `/datastores/v1/universes/{universeId}/standard-datastores/datastore/entries`,
					{
						datastoreName = datastoreName,
						cursor = cursor:asNullable(),
						limit = limit:match(function(v: number): string?
							return tostring(v)
						end, function()
							return nil
						end),
						prefix = prefix:asNullable(),
						allScopes = allScopes:match(function(v: boolean): string?
							return tostring(v)
						end, function()
							return nil
						end),
						scope = scope:unwrapOr("global") :: string,
					} :: any
				)
			)
			:build()
			:send()
			:await()
			:match(function(ok)
				local data = ok:json():unwrap()
				return result.ok({
					keys = data["keys"],
					nextPageCursor = if data["nextPageCursor"] and data["nextPageCursor"]:len() > 0
						then option.some(data["nextPageCursor"])
						else option.none(),
				})
			end, function(eResponse)
				return result.err(eResponse)
			end)
	end)
end

return Util
