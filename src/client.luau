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
local luneUtil = require("@pkg/@nightcycle/lune-util")
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

type ContentType = reqwest.ContentType
-- Constants

return {
	fromAPIKey = function()
		local keyOpt: Option<luneUtil.CompatSecret> = luneUtil.Secrets["RBX_OPEN_CLOUD_API_KEY"]
		local key = keyOpt:expect(
			`"RBX_OPEN_CLOUD_API_KEY" secret not found {if luneUtil.IS_RBX_ENV
				then "at HttpService:GetSecret or as a field of _G"
				else "in env variables"}`
		)
		local builder = reqwest.Client.new():defaultHeaders(hashMap.from({
			["x-api-key"] = key,
		}))

		return builder:build()
	end,
	fromCookie = function()
		local cookieOpt: Option<luneUtil.CompatSecret> = luneUtil.Secrets["ROBLOSECURITY"]
		local cookie = cookieOpt:expect(
			`"ROBLOSECURITY" secret not found {if luneUtil.IS_RBX_ENV
				then "at HttpService:GetSecret or as a field of _G"
				else "in env variables"}`
		)
		local builder = reqwest.Client.new():defaultHeaders(hashMap.from({
			["Cookie"] = cookie,
		}))

		return builder:build()
	end,
}
