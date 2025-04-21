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
local asset = require("./asset")
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
Util.operations = operations
Util.asset = asset

function Util.post(
	assetType: operations.AssetType,
	contentType: operations.ContentType,
	displayName: string,
	description: string,
	creatorType: operations.CreatorType,
	creatorId: number,
	data: buffer | string
): Future<Result<Response<operations.OperationData>, Response<{
	code: string,
	message: string,
}>>>
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

	return future.from(function(): any
		return client
			.fromAPIKey()
			:post(reqwest.Url.tryFrom(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/assets/v1/assets`):unwrap())
			:body(body)
			:header("Content-Type", `multipart/form-data; boundary={form.boundary}`)
			:build()
			:send()
			:await()
			:match(function(ok)
				return result.ok(ok)
			end, function(e)
				if e["errors"] then
					local eCount = #e["errors"]
					if eCount == 1 then
						local e2 = e["errors"][1]
						return result.err({
							code = "UnknownError",
							message = e2["message"],
						})
					end
				elseif typeof(e["code"]) == "string" and typeof(e["message"]) == "string" then
					return result.err({
						code = e["code"],
						message = e["message"],
					})
				end
				return result.err({
					code = "UnknownError",
					message = err.displayAsJson(e),
				})
			end)
	end)
end

return Util
