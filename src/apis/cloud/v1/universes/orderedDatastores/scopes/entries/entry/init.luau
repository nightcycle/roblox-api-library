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
local client = require("../../../../../../../../client")

-- Constants
local CONSTANTS = require("../../../../../../../../CONSTANTS")

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

-- Private Functions

-- Class
local Util = {}

function Util.get(
	universeId: number,
	datastoreName: string,
	scope: string,
	entryKey: string
): Future<Result<Response<{
	path: string,
	id: string,
	value: number,
}>, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL
						.. `/ordered-data-stores/v1/universes/{universeId}/orderedDataStores/{datastoreName}/scopes/{scope}/entries/{entryKey}`
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

function Util.patch(
	universeId: number,
	datastoreName: string,
	scope: string,
	entryKey: string,
	value: number
): Future<Result<{
	path: string,
	id: string,
	value: number,
}, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:patch(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL
						.. `/ordered-data-stores/v1/universes/{universeId}/orderedDataStores/{datastoreName}/scopes/{scope}/entries/{entryKey}`
				)
			)
			:header("Content-Type", "application/json")
			:body(reqwest.Body.fromJson({
				value = value,
			}))
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

function Util.delete(
	universeId: number,
	datastoreName: string,
	scope: string,
	entryKey: string
): Future<Result<string, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:delete(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL
						.. `/ordered-data-stores/v1/universes/{universeId}/orderedDataStores/{datastoreName}/scopes/{scope}/entries/{entryKey}`
				)
			)
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(ok)
				return result.ok(ok:text():unwrap())
			end, function(eResponse)
				return result.err(eResponse)
			end)
	end)
end

return Util
