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
-- Constants
local URL = "https://apis.roblox.com/universes/v1" -- for some reason it doesn't use the /cloud/ path
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
type PostPlaceOkData = {
	versionNumber: number,
}
export type PostPlaceErrData = {
	code: "InvalidRequest"
		| "Unauthorized"
		| "Forbidden"
		| "NotFound"
		| "Conflict"
		| "InternalServerError"
		| "UnknownError"
		| "TooManyRequests",
	message: string,
}

-- Private Functions

-- Class
local Util = {}

function Util.post(
	universeId: number,
	placeId: number,
	versionType: "Saved" | "Published",
	data: buffer | string
): Future<Result<PostPlaceOkData, PostPlaceErrData>>
	return future.from(function(): any
		return client
			.fromAPIKey()
			:post(
				reqwest.Url
					.tryFrom(URL .. `/{universeId}/places/{placeId}/versions`)
					:unwrap()
					:query(hashMap.from({
						versionType = versionType,
					}))
			)
			:body(
				reqwest.Body.fromOctetStream(
					if typeof(data) == "string" then buffer.fromstring(data) else data
				)
			)
			:header("Content-Type", "application/octet-stream")
			:build()
			:send()
			:await()
			:match(function(response)
				return result.ok(response:json():unwrap())
			end, function(response)
				if response:status() == 429 then
					return result.err({
						code = "TooManyRequests",
						message = "Rate limit exceeded",
					})
				end
				if response:status() == 401 then
					return result.err({
						code = "Unauthorized",
						message = "Invalid API Key",
					})
				end
				local body = response:json():unwrap()
				if
					body["code"] == "InvalidRequest"
					or body["code"] == "Conflict"
					or body["code"] == "NotFound"
					or body["code"] == "Forbidden"
					or body["code"] == "InternalServerError"
				then
					return result.err(body)
				end
				return result.err({
					code = "UnknownError",
					message = err.displayAsJson(response),
				})
			end)
	end)
end

return Util
