--!strict
-- Packages
local result = require("@pkg/@nightcycle/result")
local option = require("@pkg/@nightcycle/option")
local future = require("@pkg/@nightcycle/future")
local hashMap = require("@pkg/@nightcycle/hash-map")
local err = require("@pkg/@nightcycle/error")
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
): Future<Result<Response<DataStoreEntryValue>, Response<{
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
							.. `/datastores/v1/universes/{universeId}/standard-datastores/datastore/entries/entry/versions/version`
					)
					:unwrap()
					:query(hashMap.from({
						datastoreName = datastoreName,
						entryKey = entryKey,
						scope = scope:unwrapOr("global"),
						versionId = versionId,
					}))
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
							message = err.displayAsJson(e["errors"]) :: any,
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
