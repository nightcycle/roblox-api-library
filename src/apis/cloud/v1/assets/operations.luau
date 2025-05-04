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

export type AssetType = "Model" | "Decal" | "Audio" | "Video"
export type CreatorType = "User" | "Group"
export type ContentType =
	"model/fbx"
	| "image/png"
	| "image/jpeg"
	| "image/bmp"
	| "image/tga"
	| "audio/mpeg"
	| "audio/ogg"
	| "video/mp4"
	| "video/mov"
export type SocialData = {
	title: string,
	uri: string?,
}
export type PreviewData = {
	asset: string,
	altText: string?,
}
export type Object = {
	["@type"]: string,
	path: string,
	revisionCreateTime: string,
	revisionId: string,
	assetType: AssetType,
	displayName: string,
	state: "Active" | string,
	assetId: string,
	moderationResult: {
		moderationState: "Approved" | "Archived",
	},
	creationContext: {
		creator: {
			groupId: string,
		} | {
			userId: string,
		},
		description: string,
	},
	socialLink: {
		facebookSocialLink: string?,
		twitterSocialLink: string?,
		youtubeSocialLink: string?,
		twitchSocialLink: string?,
		discordSocialLink: string?,
		githubSocialLink: string?,
		robloxSocialLink: string?,
		guildedSocialLink: string?,
		devForumSocialLink: string?,
	}?,
}
export type OperationData = {
	path: string,
	done: false,
	metadata: unknown?,
	operationId: string,
} | {
	path: string,
	done: true,
	operationId: string,
	metadata: unknown?,
	response: Object,
} | {
	path: string,
	done: true,
	operationId: string,
	metadata: unknown?,
	error: unknown,
}

-- Private Functions

-- Class
local Util = {}

function Util.get(operationId: string): Future<Result<OperationData, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(reqwest.Url.from(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/assets/v1/operations/{operationId}`))
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
