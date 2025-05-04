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
local client = require("../../../../../../../client")
local instanceOperation = require("../instance/operation")
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

type EngineInstanceDetails = instanceOperation.EngineInstanceDetails
type EngineInstance = instanceOperation.EngineInstance
type CloudInstance = instanceOperation.CloudInstance

export type Operation = {
	done: false,
	path: string,
} | {
	done: true,
	response: {
		["@type"]: string,
		instances: { CloudInstance },
	},
}

-- Constants
-- Private Functions
-- Class
local Util = {}

function Util.get(path: string): Future<Result<Operation, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/cloud/v2/` .. path)
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
