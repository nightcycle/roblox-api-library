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
local client = require("../../../../../../client")
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
type PlacePublishData = {
	versionNumber: number,
}
export type PlaceData = {
	path: string,
	createTime: luneUtil.CompatDateTime,
	updateTime: luneUtil.CompatDateTime,
	displayName: string,
	description: string,
	serverSize: number,
}

-- Private Functions

-- Class
local Util = {}

function Util.post(
	universeId: number,
	placeId: number,
	versionType: "Saved" | "Published",
	data: buffer
): Future<Result<PlacePublishData, reqwest.Response>>
	return future.from(function(): any
		return client
			.fromAPIKey()
			:post(
				reqwest.Url
					.tryFrom(CONSTANTS.OPEN_CLOUD_BASE_URL_V1 .. `/universes/{universeId}/places/{placeId}/versions`)
					:unwrap()
					:query(hashMap.from({
						versionType = versionType,
					}))
			)
			:body(reqwest.Body.fromOctetStream(data))
			:header("Content-Type", "application/octet-stream")
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

function Util.update(
	universeId: number,
	placeId: number,
	displayName: Option<string>,
	description: Option<string>,
	serverSize: Option<number>
): Future<Result<PlaceData, reqwest.Response>>
end

function Util.get(universeId: number, placeId: number): Future<Result<PlaceData, reqwest.Response>> end

return Util
