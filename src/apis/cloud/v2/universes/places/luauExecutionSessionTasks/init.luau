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
local client = require("../../../../../../client")
local versions = require("./versions")
-- Constants
local CONSTANTS = require("../../../../../../CONSTANTS")
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
Util.versions = versions

function Util.post<V>(
	universeId: number,
	placeId: number,
	content: string,
	timeout: Option<number>
): Future<
	Result<Result<versions.OkLuauExecutionTask, versions.ErrLuauExecutionTask>, Response<unknown>>
>
	return future.from(function()
		return client
			.fromAPIKey()
			:post(
				CONSTANTS.OPEN_CLOUD_BASE_URL
					.. `/cloud/v2/universes/{universeId}/places/{placeId}/luau-execution-session-tasks`
			)
			:body(reqwest.Body.fromJson({
				script = content,
				timeout = timeout:match(function(v): string?
					return `{v}s`
				end, function()
					return nil
				end),
			}))
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(response)
				return result.ok(versions._parseResponse(response))
			end, function(response)
				return result.err(response)
			end)
	end)
end

function Util.get<V>(path: string): Future<
	Result<Result<versions.OkLuauExecutionTask, versions.ErrLuauExecutionTask>, Response<unknown>>
>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/cloud/v2/{path}`)
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(response)
				return result.ok(versions._parseResponse(response))
			end, function(response)
				return result.err(response)
			end)
	end)
end

return Util
