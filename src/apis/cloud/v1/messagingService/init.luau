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
-- Modules
local client = require("../../../../client")
-- Constants
local CONSTANTS = require("../../../../CONSTANTS")
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

-- Private Functions

-- Class
local Util = {}

function Util.post(
	universeId: number,
	topic: string,
	message: string
): Future<
	Result<
		Response<string>,
		Response<
			{
				Error: "InvalidRequest"
					| "Unauthorized"
					| "Forbidden"
					| "InternalServerError"
					| "UnknownError"
					| "TooManyRequests",
				Message: string,
			}
			| { errors: { { code: number, message: string } } }
			| string
		>
	>
>
	return future.from(function(): any
		return client
			.fromAPIKey()
			:post(
				reqwest.Url
					.tryFrom(
						CONSTANTS.OPEN_CLOUD_BASE_URL
							.. `/messaging-service/v1/universes/{universeId}/topics/{topic}`
					)
					:unwrap()
			)
			:body(reqwest.Body.fromJson({
				message = message,
			}))
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
	end)
end

return Util
