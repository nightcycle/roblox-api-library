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
local entry = require("./entry")

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
Util.entry = entry

function Util.post(
	universeId: number,
	datastoreName: string,
	scope: string,
	entryKey: string,
	value: number
): Future<Result<Response<{
	path: string,
	id: string,
}>, Response<{
	code: string,
	message: string,
}>>>
	return future.from(function(): any
		return client
			.fromAPIKey()
			:post(
				reqwest.Url
					.tryFrom(
						CONSTANTS.OPEN_CLOUD_BASE_URL
							.. `/ordered-data-stores/v1/universes/{universeId}/orderedDataStores/{datastoreName}/scopes/{scope}/entries`
					)
					:unwrap()
					:query({
						id = entryKey,
					})
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

function Util.get(
	universeId: number,
	datastoreName: string,
	scope: string,
	cursor: Option<string>,
	limit: Option<number>,
	minValue: Option<number>,
	maxValue: Option<number>,
	orderBy: Option<"desc">
): Future<Result<Response<{
	keys: { { path: string, id: string, value: number } },
	nextPageCursor: string,
}>, Response<{
	code: string | "JsonDecodeError",
	message: string,
}>>>
	return future.from(function(): any
		return client
			.fromAPIKey()
			:get(
				reqwest.Url
					.tryFrom(
						CONSTANTS.OPEN_CLOUD_BASE_URL
							.. `/ordered-data-stores/v1/universes/{universeId}/orderedDataStores/{datastoreName}/scopes/{scope}/entries`
					)
					:unwrap()
					:query(hashMap.from({
						page_token = cursor:asNullable(),
						max_page_size = limit:asNullable(),
						order_by = orderBy:asNullable(),
						filter = minValue:match(function(min): string?
							return maxValue:match(function(max): string?
								return `entry <= {max} && entry >= {min}`
							end, function()
								return `entry >= {min}`
							end)
						end, function(): string?
							return maxValue:match(function(max): string?
								return `entry <= {max}`
							end, function()
								return nil
							end)
						end),
					}))
			)
			:build()
			:send()
			:await()
			:match(function(ok)
				return ok:json():match(function(json)
					-- print(`typeof: {typeof(json)}`)
					return result.ok(ok:builder()
						:body(reqwest.Body.fromJson({
							keys = json["keys"],
							nextPageCursor = json["nextPageCursor"] or "",
						}))
						:build())
				end, function(e)
					return result.err(ok:builder()
						:body(reqwest.Body.fromJson({
							code = "JsonDecodeError",
							message = err.displayAsJson(e),
						}))
						:build())
				end)
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
