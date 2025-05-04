--!strict
-- Packages
local result = require("@pkg/@nightcycle/result")
local option = require("@pkg/@nightcycle/option")
local future = require("@pkg/@nightcycle/future")
local reqwest = require("@pkg/@nightcycle/reqwest")
local luneUtil = require("@pkg/@nightcycle/lune-util")

-- Modules
local client = require("../../../../../../../../../client")

-- Constants
local CONSTANTS = require("../../../../../../../../../CONSTANTS")

-- Types
type Result<V, E> = result.Result<V, E>
type Option<V> = option.Option<V>
type Future<V> = future.Future<V>
type Response<B> = reqwest.Response<B>
type CompatDateTime = luneUtil.CompatDateTime
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local Util = {}

-- lists the datastores
function Util.get(
	universeId: number,
	datastoreName: string,
	entryKey: string,
	scope: Option<string>,
	cursor: Option<string>,
	startTime: Option<CompatDateTime>,
	endTime: Option<CompatDateTime>,
	sortOrder: Option<"Ascending" | "Descending">,
	limit: Option<number>
): Future<Result<{
	versions: {
		{
			version: string,
			deleted: boolean,
			contentLength: number,
			createdTime: string,
			objectCreatedTime: string,
		}
	},
	nextPageCursor: string,
}, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(
				reqwest.Url.from(
					CONSTANTS.OPEN_CLOUD_BASE_URL
						.. `/datastores/v1/universes/{universeId}/standard-datastores/datastore/entries/entry/versions`,
					{
						datastoreName = datastoreName,
						entryKey = entryKey,
						scope = scope:unwrapOr("global"),
						cursor = cursor:asNullable(),
						startTime = startTime:match(function(t): string?
							return t:formatIsoDate()
						end, function()
							return nil
						end),
						endTime = endTime:match(function(t): string?
							return t:formatIsoDate()
						end, function()
							return nil
						end),
						sortOrder = sortOrder:asNullable(),
						limit = limit:asNullable(),
					} :: { [string]: any }
				)
			)
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(ok)
				return result.ok(ok:json():unwrap())
			end, function(eResponse)
				return result.err(eResponse)
			end)
	end)
end

return Util
