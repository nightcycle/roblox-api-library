--!strict
-- Packages
local result = require("@pkg/@nightcycle/result")
local option = require("@pkg/@nightcycle/option")
local future = require("@pkg/@nightcycle/future")
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
): Future<Result<{
	path: string,
	id: string,
	value: number,
}, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:post(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL
						.. `/ordered-data-stores/v1/universes/{universeId}/orderedDataStores/{datastoreName}/scopes/{scope}/entries/{entryKey}:increment`
				)
			)
			:body(reqwest.Body.fromJson({
				amount = delta,
			}))
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(ok)
				return result.ok(ok:json():unwrap())
			end, function(e)
				return result.err(e)
			end)
	end)
end

return Util
