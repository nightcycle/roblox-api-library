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
type Response<B> = reqwest.Response<B>
export type ViewType = "FLAT" | "STRUCTURED"
export type StructuredMessageType = "MESSAGE_TYPE_UNSPECIFIED" | "OUTPUT" | "INFO" | "WARNING" | "ERROR"
type StructuredMessage = {
	message: string,
	createTime: luneUtil.CompatDateTime,
	messageType: StructuredMessageType,
}
type LuauExecutionSessionTaskLog = {
	path: string,
	messages: { string },
	structuredMessages: { StructuredMessage },
}
type LuauExecutionSessionTaskBody = {
	luauExecutionSessionTaskLogs: { LuauExecutionSessionTaskLog },
	nextPageToken: string,
}
-- Constants

-- Private Functions
-- Class
local Util = {}

function Util.get<V>(
	path: string,
	view: ViewType,
	pageToken: Option<string>,
	maxPageSize: Option<number>
): Future<Result<LuauExecutionSessionTaskBody, Response<unknown>>>
	return future.from(function()
		return client
			.fromAPIKey()
			:get(reqwest.Url.from(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/cloud/v2/` .. path .. "/logs", {
				maxPageSize = maxPageSize:asNullable() :: any,
				pageToken = pageToken:asNullable(),
				view = view :: string,
			}))
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(response)
				local data = response:json():unwrap()
				local output: LuauExecutionSessionTaskBody = {
					luauExecutionSessionTaskLogs = {} :: { LuauExecutionSessionTaskLog },
					nextPageToken = data.nextPageToken,
				}
				for i, log in ipairs(data.luauExecutionSessionTaskLogs) do
					local structuredMessages: { StructuredMessage } = {}
					for _, message in ipairs(log.structuredMessages) do
						local structuredMessage: StructuredMessage = {
							message = message.message,
							createTime = luneUtil.DateTime.fromIsoDate(message.createTime),
							messageType = message.messageType,
						}
						table.insert(structuredMessages, structuredMessage)
					end
					log.structuredMessages = structuredMessages :: any
					output.luauExecutionSessionTaskLogs[i] = {
						path = log.path,
						messages = log.messages,
						structuredMessages = structuredMessages,
					}
				end

				return result.ok(output)
			end, function(response)
				return result.err(response)
			end)
	end)
end

return Util
