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
local client = require("../../../../../client")
local restore = require("./restore")
local archive = require("./archive")
local versions = require("./versions")
local operations = require("../operations")
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

-- Private Functions

-- Class
local Util = {}
Util.restore = restore
Util.archive = archive
Util.versions = versions

function Util.get(
	assetId: number,
	readMask: {
		description: true?,
		displayName: true?,
		icon: true?,
		previews: true?,
		facebookSocialLink: true?,
		twitterSocialLink: true?,
		youtubeSocialLink: true?,
		twitchSocialLink: true?,
		discordSocialLink: true?,
		githubSocialLink: true?,
		robloxSocialLink: true?,
		guildedSocialLink: true?,
		devForumSocialLink: true?,
	}
): Future<Result<operations.OperationData, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(reqwest.Url.from(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/assets/v1/assets/{assetId}`, {
				readMask = table.concat(hashMap.from(readMask):intoKeys():drain(), "%2C"),
			}))
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

function Util.patch(
	assetId: number,
	content: Option<buffer | string>,
	info: Option<{
		icon: string?,
		displayName: string?,
		description: string?,
	}>,
	previews: Option<Vec<operations.PreviewData>>,
	socialLinks: Option<{
		facebookSocialLink: operations.SocialData?,
		twitterSocialLink: operations.SocialData?,
		youtubeSocialLink: operations.SocialData?,
		twitchSocialLink: operations.SocialData?,
		discordSocialLink: operations.SocialData?,
		githubSocialLink: operations.SocialData?,
		robloxSocialLink: operations.SocialData?,
		guildedSocialLink: operations.SocialData?,
		devForumSocialLink: operations.SocialData?,
	}>
): Future<Result<operations.OperationData, Response<unknown>>>
	local updateMask: { string } = {}

	local fields = hashMap.fromMut({})

	if content:isSome() then
		error("Wasn't ever able to get patch content to work, so this is disabled for now")
	end

	info:inspect(function(v)
		if v["displayName"] then
			table.insert(updateMask, "displayName")
		end
		if v["description"] then
			table.insert(updateMask, "description")
		end
		if v["icon"] then
			table.insert(updateMask, "icon")
		end

		local request = {
			assetId = tostring(assetId),
			displayName = v["displayName"],
			description = v["description"],
			icon = v["icon"],
			previews = previews:match(function(pVec): { operations.PreviewData }?
				table.insert(updateMask, "previews")
				local out = {}
				pVec:forEach(function(v)
					table.insert(out, v)
				end)
				return out
			end, function()
				return nil
			end),
		}
		socialLinks:inspect(function(links)
			for k, v in pairs(links) do
				if v then
					table.insert(updateMask, k)
					request[k] = v
				end
			end
		end)
		fields:insert("request", request)
	end)

	local files = hashMap.fromMut({})

	content:inspect(function(v)
		files:insert("fileContent", {
			fileName = `file.png`,
			data = if typeof(v) == "buffer" then buffer.tostring(v) else v,
		})
	end)

	if fields:get("request"):isNone() then
		fields:insert("request", {
			assetId = math.round(assetId),
		})
	end

	local body = reqwest.Body.fromForm(fields:freeze(), files:freeze(), option.none())
	local form = body:asForm():unwrap()

	return future.from(function()
		local request = client
			.fromAPIKey()
			:patch(reqwest.Url.from(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/assets/v1/assets/{assetId}`, {
				updateMask = if #updateMask > 0 then table.concat(updateMask, "%2C") else nil,
			}))
			:body(body)
			:header("Content-Type", `multipart/form-data; boundary={form.boundary}`)
			:build()

		return request:send():await():match(function(ok)
			return result.ok(ok:json():unwrap())
		end, function(e)
			return result.err(e)
		end)
	end)
end

return Util
