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
-- Modules
local client = require("../../../../client")
local operations = require("./operations")
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
	assetType: operations.AssetType,
	contentType: operations.ContentType,
	displayName: string,
	description: string,
	creatorType: operations.CreatorType,
	creatorId: number,
	data: buffer | string
): Future<Result<operations.OperationData, Response<unknown>>>
	local fileExt = contentType:split("/")[2]
	assert(fileExt, "Invalid content type")
	local body = reqwest.Body.fromForm(
		hashMap.from({
			request = luneUtil.Net.jsonEncode({
				assetType = assetType,
				displayName = displayName,
				description = description,
				creationContext = if creatorType == "User"
					then {
						creator = {
							userId = tostring(creatorId),
						},
					}
					else {
						creator = {
							groupId = tostring(creatorId),
						},
					},
			}),
		}),
		hashMap.from({
			fileContent = {
				fileName = `file.{fileExt}`,
				contentType = contentType,
				data = data,
			},
		}),
		option.none()
	)
	local form = body:asForm():unwrap()

	return future.from(function()
		return client
			.fromAPIKey()
			:post(reqwest.Url.from(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/assets/v1/assets`))
			:body(body)
			:header("Content-Type", `multipart/form-data; boundary={form.boundary}`)
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
