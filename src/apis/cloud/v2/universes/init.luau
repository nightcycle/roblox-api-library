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
type VisibilityType = "VISIBILITY_UNSPECIFIED" | "PUBLIC" | "PRIVATE"
type AgeRating =
	"AGE_RATING_UNSPECIFIED"
	| "AGE_RATING_ALL"
	| "AGE_RATING_9_PLUS"
	| "AGE_RATING_13_PLUS"
	| "AGE_RATING_17_PLUS"

type SocialLink = {
	title: string,
	uri: string,
}
type Universe = {
	path: string,
	createTime: luneUtil.CompatDateTime,
	updateTime: luneUtil.CompatDateTime,
	displayName: string,
	description: string,
	user: Option<string>,
	group: Option<string>,
	visibility: VisibilityType,
	facebookSocialLink: Option<SocialLink>,
	twitterSocialLink: Option<SocialLink>,
	youtubeSocialLink: Option<SocialLink>,
	twitchSocialLink: Option<SocialLink>,
	discordSocialLink: Option<SocialLink>,
	robloxGroupSocialLink: Option<SocialLink>,
	guildedSocialLink: Option<SocialLink>,
	voiceChatEnabled: boolean,
	ageRating: AgeRating,
	privateServerPriceRobux: Option<number>,
	desktopEnabled: boolean,
	mobileEnabled: boolean,
	tabletEnabled: boolean,
	consoleEnabled: boolean,
	vrEnabled: boolean,
}
type PartialUniverse = {
	facebookSocialLink: SocialLink?,
	twitterSocialLink: SocialLink?,
	youtubeSocialLink: SocialLink?,
	twitchSocialLink: SocialLink?,
	discordSocialLink: SocialLink?,
	robloxGroupSocialLink: SocialLink?,
	guildedSocialLink: SocialLink?,
	voiceChatEnabled: boolean?,
	privateServerPriceRobux: number?,
	desktopEnabled: boolean?,
	mobileEnabled: boolean?,
	tabletEnabled: boolean?,
	consoleEnabled: boolean?,
	vrEnabled: boolean?,
}

-- Constants

-- Private Functions
function parseUniverseBody(body: any): Universe
	return {
		path = body.path,
		createTime = luneUtil.DateTime.fromIsoDate(body.createTime),
		updateTime = luneUtil.DateTime.fromIsoDate(body.updateTime),
		displayName = body.displayName,
		description = body.description,
		user = option.from(body.user),
		group = option.from(body.group),
		visibility = body.visibility,
		facebookSocialLink = option.from(body.facebookSocialLink),
		twitterSocialLink = option.from(body.twitterSocialLink),
		youtubeSocialLink = option.from(body.youtubeSocialLink),
		twitchSocialLink = option.from(body.twitchSocialLink),
		discordSocialLink = option.from(body.discordSocialLink),
		robloxGroupSocialLink = option.from(body.robloxGroupSocialLink),
		guildedSocialLink = option.from(body.guildedSocialLink),
		voiceChatEnabled = body.voiceChatEnabled,
		ageRating = body.ageRating,
		privateServerPriceRobux = option.from(body.privateServerPriceRobux),
		desktopEnabled = body.desktopEnabled,
		mobileEnabled = body.mobileEnabled,
		tabletEnabled = body.tabletEnabled,
		consoleEnabled = body.consoleEnabled,
		vrEnabled = body.vrEnabled,
	}
end

-- Class
local Util = {}
Util.publishMessage = require("./publishMessage")
Util.restartServers = require("./restartServers")

function Util.get<V>(universeId: number): Future<Result<Universe, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/cloud/v2/universes/{universeId}`)
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(response)
				return result.ok(parseUniverseBody(response:json():unwrap()))
			end, function(response)
				return result.err(response)
			end)
	end)
end

function Util.patch<V>(universeId: number, data: PartialUniverse): Future<Result<Universe, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:patch(reqwest.Url.from(
				CONSTANTS.OPEN_CLOUD_BASE_URL .. `/cloud/v2/universes/{universeId}`,
				{
					updateMask = table.concat(hashMap.from(data):intoKeys():drain(), "%2C"),
				} :: any
			))
			:header("Content-Type", "application/json")
			:body(reqwest.Body.fromJson(data))
			:build()
			:send()
			:await()
			:match(function(response)
				return result.ok(parseUniverseBody(response:json():unwrap()))
			end, function(response)
				return result.err(response)
			end)
	end)
end

return Util
