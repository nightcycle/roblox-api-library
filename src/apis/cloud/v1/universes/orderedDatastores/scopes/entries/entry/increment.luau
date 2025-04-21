--!strict
-- Packages
local result = require("@pkg/@nightcycle/result")
local option = require("@pkg/@nightcycle/option")
local future = require("@pkg/@nightcycle/future")
local err = require("@pkg/@nightcycle/error")
local reqwest = require("@pkg/@nightcycle/reqwest")

-- Modules
local client = require("../../../../../../../../client")

-- Constants
local CONSTANTS = require("../../../../../../../../CONSTANTS")

-- Types
type Result<V, E> = result.Result<V, E>
type Option<V> = option.Option<V>
type Future<V> = future.Future<V>
type Response<B> = reqwest.Response<B>
-- Private Functions

-- Class
local Util = {}

-- lists the datastores
function Util.post(
	universeId: number,
	datastoreName: string,
	scope: string,
	entryKey: string,
	delta: number
): Future<Result<Response<{
	path: string,
	id: string,
	value: number,
}>, Response<{
	code: string,
	message: string,
}>>>
	print(`Incrementing entry "{entryKey}" in datastore "{datastoreName}" in universe "{universeId}"`)
	return future.from(function(): any
		return client
			.fromAPIKey()
			:post(
				reqwest.Url
					.tryFrom(
						CONSTANTS.OPEN_CLOUD_BASE_URL
							.. `/ordered-data-stores/v1/universes/{universeId}/orderedDataStores/{datastoreName}/scopes/{scope}/entries/{entryKey}:increment`
					)
					:unwrap()
			)
			:body(reqwest.Body.fromJson({
				amount = delta,
			}))
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
