--!strict
-- Packages
local result = require("@pkg/@nightcycle/result")
local option = require("@pkg/@nightcycle/option")
local future = require("@pkg/@nightcycle/future")
local hashMap = require("@pkg/@nightcycle/hash-map")
local vec = require("@pkg/@nightcycle/vec")
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
type Error<V, B> = err.Error<V, B>
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
function Util.post(
	universeId: number,
	datastoreName: string,
	entryKey: string,
	delta: number,
	scope: Option<string>,
	exclusiveCreate: Option<boolean>,
	robloxEntryAttributes: Option<HashMap<string, boolean | number | string>>,
	robloxEntryUserIds: Option<Vec<number>>
): Future<Result<Response<{
	sum: number,
}>, Response<{
	code: string,
	message: string,
}>>>
	return future.from(function(): any
		local baseRequest = client
			.fromAPIKey()
			:post(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL
						.. `/datastores/v1/universes/{universeId}/standard-datastores/datastore/entries/entry/increment`,
					{
						datastoreName = datastoreName,
						entryKey = entryKey,
						scope = scope:unwrapOr("global"),
						exclusiveCreate = exclusiveCreate:match(function(v): string?
							return tostring(v)
						end, function()
							return nil
						end),
						incrementBy = tostring(delta),
					}
				)
			)
			:header("Content-Type", "application/json")

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
			local txt = ok:text():expect("Failed to parse response as text")
			local num = tonumber(txt)
			assert(num, `Failed to parse response as number: "{txt}"`)
			return result.ok(ok:builder()
				:body(reqwest.Body.fromJson({
					sum = num,
				}))
				:build())
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
							}) :: reqwest.Body<any>)
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
