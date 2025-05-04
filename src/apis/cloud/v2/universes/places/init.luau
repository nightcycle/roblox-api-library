--!strict
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local result = require("@pkg/@nightcycle/result")
local option = require("@pkg/@nightcycle/option")
local future = require("@pkg/@nightcycle/future")
local hashMap = require("@pkg/@nightcycle/hash-map")
local vec = require("@pkg/@nightcycle/vec")
local vecDeque = require("@pkg/@nightcycle/vec-deque")
local err = require("@pkg/@nightcycle/error")
local reqwest = require("@pkg/@nightcycle/reqwest")
-- Modules
local client = require("../../../../../client")
-- Constants
local CONSTANTS = require("../../../../../CONSTANTS")
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
type Place = {
	path: string,
	createTime: luneUtil.CompatDateTime,
	updateTime: luneUtil.CompatDateTime,
	displayName: string,
	description: string,
	serverSize: number,
}
-- Constants

-- Private Functions
function parseBody(body: any): Place
	return {
		path = body.path,
		createTime = luneUtil.DateTime.fromIsoDate(body.createTime),
		updateTime = luneUtil.DateTime.fromIsoDate(body.updateTime),
		displayName = body.displayName,
		description = body.description,
		serverSize = body.serverSize,
	}
end
-- Class
local Util = {}
Util.instances = require("./instances")
Util.luauExecutionSessionTasks = require("./luauExecutionSessionTasks")

function Util.get<V>(universeId: number, placeId: number): Future<Result<Place, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/cloud/v2/universes/{universeId}/places/{placeId}`)
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(response)
				return result.ok(parseBody(response:json():unwrap()))
			end, function(response)
				return result.err(response)
			end)
	end)
end

function Util.patch<V>(
	universeId: number,
	placeId: number,
	displayName: Option<string>,
	description: Option<string>,
	serverSize: Option<number>
): Future<Result<Place, Response<unknown>>>
	local data = {
		displayName = displayName:asNullable(),
		description = description:asNullable(),
		serverSize = serverSize:asNullable(),
	}
	return future.from(function()
		return client
			.fromAPIKey()
			:patch(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL .. `/cloud/v2/universes/{universeId}/places/{placeId}`,
					{
						updateMask = table.concat(hashMap.from(data):intoKeys():drain(), "%2C"),
					} :: any
				)
			)
			:header("Content-Type", "application/json")
			:body(reqwest.Body.fromJson(data))
			:build()
			:send()
			:await()
			:match(function(response)
				return result.ok(parseBody(response:json():unwrap()))
			end, function(response)
				return result.err(response)
			end)
	end)
end

return Util
