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
local hashLib = require("@pkg/@nightcycle/hashlib")

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
type DataStoreEntryValue =
	boolean
	| number
	| string
	| { DataStoreEntryValue }
	| { [string]: DataStoreEntryValue }
-- Private Functions

-- Class
local Util = {}

Util.increment = require("./increment")
Util.versions = require("./versions")

function Util.get(
	universeId: number,
	datastoreName: string,
	entryKey: string,
	scope: Option<string>
): Future<Result<DataStoreEntryValue, Response<{
	code: string,
	message: string,
}>>>
	return future.from(function(): any
		return client
			.fromAPIKey()
			:get(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL
						.. `/datastores/v1/universes/{universeId}/standard-datastores/datastore/entries/entry`,
					{
						datastoreName = datastoreName,
						entryKey = entryKey,
						scope = scope:unwrapOr("global"),
					} :: any
				)
			)
			:header("Content-Type", "application/x-www-form-urlencoded")
			:build()
			:send()
			:await()
			:match(function(ok)
				return result.ok(ok:json():unwrap())
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

function Util.post(
	universeId: number,
	datastoreName: string,
	entryKey: string,
	value: DataStoreEntryValue,
	scope: Option<string>,
	matchVersion: Option<string>,
	exclusiveCreate: Option<boolean>,
	robloxEntryAttributes: Option<HashMap<string, boolean | number | string>>,
	robloxEntryUserIds: Option<Vec<number>>
): Future<Result<{
	version: string,
	deleted: boolean,
	contentLength: number,
	createdTime: string,
	objectCreatedTime: string,
}, Response<{
	code: string,
	message: string,
}>>>
	local body: reqwest.Body<any> = if typeof(value) == "string"
		then reqwest.Body.fromText('"' .. value:gsub('"', '\\"') .. '"')
		elseif typeof(value) == "boolean" or typeof(value) == "number" then reqwest.Body.fromText(
			tostring(value)
		)
		else reqwest.Body.fromJson(value)

	return future.from(function()
		local baseRequest = client
			.fromAPIKey()
			:post(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL
						.. `/datastores/v1/universes/{universeId}/standard-datastores/datastore/entries/entry`,
					{
						datastoreName = datastoreName,
						entryKey = entryKey,
						scope = scope:unwrapOr("global"),
						matchVersion = matchVersion:asNullable() :: any,
						exclusiveCreate = exclusiveCreate:asNullable() :: any,
					} :: any
				)
			)
			:header("Content-Type", "application/json")
			:body(body)

		body:asText():inspect(function(text: string)
			baseRequest = baseRequest:header(
				"content-md5",
				hashLib.base64_encode(hashLib.hex_to_bin(hashLib.md5(text)))
			)
		end)

		baseRequest = robloxEntryAttributes:match(
			function(attributes: HashMap<string, boolean | number | string>)
				if attributes:len() > 0 then
					return baseRequest:header(
						"roblox-entry-attributes",
						luneUtil.Net.jsonEncode(attributes:drain())
					)
				else
					return baseRequest
				end
			end,
			function()
				return baseRequest
			end
		)

		baseRequest = robloxEntryUserIds:match(function(userIds: Vec<number>)
			if userIds:len() > 0 then
				return baseRequest:header("roblox-entry-userids", luneUtil.Net.jsonEncode(userIds:drain()))
			else
				return baseRequest
			end
		end, function()
			return baseRequest
		end)

		return baseRequest:build():send():await():match(function(ok)
			return result.ok(ok:json():unwrap())
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
	entryKey: string,
	scope: Option<string>
): Future<Result<string, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:delete(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL
						.. `/datastores/v1/universes/{universeId}/standard-datastores/datastore/entries/entry`,
					{
						datastoreName = datastoreName,
						entryKey = entryKey,
						scope = scope:unwrapOr("global"),
					} :: any
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
