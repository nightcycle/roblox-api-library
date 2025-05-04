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

-- Constants

-- Private Functions

-- Class
local Util = {}
Util.places = require("./places")

function Util.post<V>(universeId: number, topic: string, message: string): Future<Result<{}, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:post(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/cloud/v2/universes/{universeId}:publishMessage`)
			:header("Content-Type", "application/json")
			:body(reqwest.Body.fromJson({
				topic = topic,
				message = message,
			}))
			:build()
			:send()
			:await()
			:match(function(response)
				return result.ok(response:json():unwrap())
			end, function(response)
				return result.err(response)
			end)
	end)
end

return Util
