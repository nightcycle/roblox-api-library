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
local increment = require("./increment")

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
Util.increment = increment

function Util.get(
	universeId: number,
	datastoreName: string,
	scope: string,
	entryKey: string
): Future<Result<Response<{
	path: string,
	id: string,
	value: number,
}>, Response<{
	code: string,
	message: string,
}>>>
	return future.from(function(): any
		return client
			.fromAPIKey()
			:get(
				reqwest.Url
					.tryFrom(
						CONSTANTS.OPEN_CLOUD_BASE_URL
							.. `/ordered-data-stores/v1/universes/{universeId}/orderedDataStores/{datastoreName}/scopes/{scope}/entries/{entryKey}`
					)
					:unwrap()
			)
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(ok)
				return result.ok(ok)
			end, function(eResponse)
				local eBuilder = eResponse:builder()
				return eResponse:json():match(function(e)
					if e["errors"] then
						local eCount = #e["errors"]
						if eCount == 1 then
							local e2 = e["errors"][1]
							return result.err(eBuilder
								:body(reqwest.Body.fromJson({
									code = "UnknownError",
									message = e2["message"],
								}))
								:build())
						end
					elseif typeof(e["code"]) == "string" and typeof(e["message"]) == "string" then
						return result.err(eBuilder
							:body(reqwest.Body.fromJson({
								code = e["code"],
								message = e["message"],
							}))
							:build())
					end
					return result.err(eBuilder
						:body(reqwest.Body.fromJson({
							code = "UnknownError",
							message = err.displayAsJson(e) :: any,
						}))
						:build())
				end, function(e)
					return result.err(eBuilder
						:body(reqwest.Body.fromJson({
							code = "UnknownError",
							message = err.displayAsJson(e :: any),
						}))
						:build())
				end)
			end)
	end)
end

function Util.patch(
	universeId: number,
	datastoreName: string,
	scope: string,
	entryKey: string,
	value: number
): Future<Result<Response<{
	path: string,
	id: string,
	value: number,
}>, Response<{
	code: string,
	message: string,
}>>>
	return future.from(function(): any
		return client
			.fromAPIKey()
			:patch(
				reqwest.Url
					.tryFrom(
						CONSTANTS.OPEN_CLOUD_BASE_URL
							.. `/ordered-data-stores/v1/universes/{universeId}/orderedDataStores/{datastoreName}/scopes/{scope}/entries/{entryKey}`
					)
					:unwrap()
			)
			:header("Content-Type", "application/json")
			:body(reqwest.Body.fromJson({
				value = value,
			}))
			:build()
			:send()
			:await()
			:match(function(ok)
				return result.ok(ok)
			end, function(eResponse)
				local eBuilder = eResponse:builder()
				return eResponse:json():match(function(e)
					if e["errors"] then
						local eCount = #e["errors"]
						if eCount == 1 then
							local e2 = e["errors"][1]
							return result.err(eBuilder
								:body(reqwest.Body.fromJson({
									code = "UnknownError",
									message = e2["message"],
								}))
								:build())
						end
					elseif typeof(e["code"]) == "string" and typeof(e["message"]) == "string" then
						return result.err(eBuilder
							:body(reqwest.Body.fromJson({
								code = e["code"],
								message = e["message"],
							}))
							:build())
					end
					return result.err(eBuilder
						:body(reqwest.Body.fromJson({
							code = "UnknownError",
							message = err.displayAsJson(e) :: any,
						}))
						:build())
				end, function(e)
					return result.err(eBuilder
						:body(reqwest.Body.fromJson({
							code = "UnknownError",
							message = err.displayAsJson(e :: any),
						}))
						:build())
				end)
			end)
	end)
end

function Util.delete(
	universeId: number,
	datastoreName: string,
	scope: string,
	entryKey: string
): Future<Result<Response<string>, Response<{}>>>
	return future.from(function(): any
		return client
			.fromAPIKey()
			:delete(
				reqwest.Url
					.tryFrom(
						CONSTANTS.OPEN_CLOUD_BASE_URL
							.. `/ordered-data-stores/v1/universes/{universeId}/orderedDataStores/{datastoreName}/scopes/{scope}/entries/{entryKey}`
					)
					:unwrap()
			)
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(ok)
				return result.ok(ok)
			end, function(eResponse)
				local eBuilder = eResponse:builder()
				return eResponse:json():match(function(e)
					if e["errors"] then
						local eCount = #e["errors"]
						if eCount == 1 then
							local e2 = e["errors"][1]
							return result.err(eBuilder
								:body(reqwest.Body.fromJson({
									code = "UnknownError",
									message = e2["message"],
								}))
								:build())
						end
					elseif typeof(e["code"]) == "string" and typeof(e["message"]) == "string" then
						return result.err(eBuilder
							:body(reqwest.Body.fromJson({
								code = e["code"],
								message = e["message"],
							}))
							:build())
					end
					return result.err(eBuilder
						:body(reqwest.Body.fromJson({
							code = "UnknownError",
							message = err.displayAsJson(e) :: any,
						}))
						:build())
				end, function(e)
					return result.err(eBuilder
						:body(reqwest.Body.fromJson({
							code = "UnknownError",
							message = err.displayAsJson(e :: any),
						}))
						:build())
				end)
			end)
	end)
end

return Util
