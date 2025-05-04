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
local client = require("../../../../../../../client")
-- Constants
local CONSTANTS = require("../../../../../../../CONSTANTS")
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
export type LuauTaskState = "STATE_UNSPECIFIED" | "QUEUED" | "PROCESSING" | "CANCELLED" | "COMPLETE" | "FAILED"
export type LuauTaskErrorState =
	"ERROR_CODE_UNSPECIFIED"
	| "SCRIPT_ERROR"
	| "DEADLINE_EXCEEDED"
	| "OUTPUT_SIZE_LIMIT_EXCEEDED"
	| "INTERNAL_ERROR"

type LuauExecutionOutput<V> = {
	results: { V },
}
type ErrorResponse<V> = {
	code: V,
	message: string,
}
type BaseLuauExecutionTask = {
	path: string,
	createTime: luneUtil.CompatDateTime?,
	updateTime: luneUtil.CompatDateTime?,
	timeout: string?,
	user: string,
	state: LuauTaskState,
	script: string?,
}
type OkLuauExecutionTask<V> = BaseLuauExecutionTask & {
	output: LuauExecutionOutput<V>?,
}
type ErrLuauExecutionTask = BaseLuauExecutionTask & {
	error: ErrorResponse<LuauTaskErrorState>,
}

export type LuauExecutionTask<V> = OkLuauExecutionTask<V> | ErrLuauExecutionTask

-- Constants

-- Private Functions
function parseBaseResponse(jsonResponse: { [string]: unknown? }): BaseLuauExecutionTask
	print(err.displayAsJson(jsonResponse, 5))
	local path = jsonResponse["path"]
	assert(typeof(path) == "string", "Path is not a string")
	local createTimeStr = jsonResponse["createTime"]
	assert(typeof(createTimeStr) == "string" or typeof(createTimeStr) == "nil", "CreateTime is not a string")
	local createTime = if createTimeStr then luneUtil.DateTime.fromIsoDate(createTimeStr) else nil
	local updateTimeString = jsonResponse["updateTime"]
	assert(
		typeof(updateTimeString) == "string" or typeof(updateTimeString) == "nil",
		"UpdateTime is not a string"
	)
	local updateTime = if updateTimeString then luneUtil.DateTime.fromIsoDate(updateTimeString) else nil
	local user = jsonResponse["user"]
	assert(typeof(user) == "string", "User is not a string")
	local state: LuauTaskState = jsonResponse["state"] :: any
	assert(typeof(state) == "string", "State is not a string")

	local timeoutStr = jsonResponse["timeout"]
	assert(typeof(timeoutStr) == "string" or typeof(timeoutStr) == "nil", "Timeout is not a string")

	local scriptStr = jsonResponse["script"]
	assert(typeof(scriptStr) == "string", "Script is not a string")

	return {
		path = path,
		createTime = createTime,
		updateTime = updateTime,
		timeout = option.from(timeoutStr):asNullable(),
		user = user,
		state = state,
		script = (if scriptStr:len() > 0 then scriptStr else nil),
	}
end

function parseResponse<V>(response: Response<any>): Result<OkLuauExecutionTask<V>, ErrLuauExecutionTask>
	local json: { [string]: unknown? } = response:json():unwrap() :: any
	if json["error"] then
		local errTask = parseBaseResponse(json) :: ErrLuauExecutionTask
		local eField = json["error"] :: any
		assert(typeof(eField) == "table", "error is not a table")
		local code = eField["code"]
		assert(typeof(code) == "string", "error code is not a string")
		local message = eField["message"]
		assert(typeof(message) == "string", "error message is not a string")
		local errResponse: ErrorResponse<LuauTaskErrorState> = {
			code = code :: LuauTaskErrorState,
			message = message,
		}
		errTask["error"] = errResponse
		return result.err(errTask :: any)
	else
		local okTask = parseBaseResponse(json) :: OkLuauExecutionTask<V>

		if json["output"] ~= nil then
			local output: { [string]: unknown? } = json["output"] :: any
			assert(typeof(output) == "table", "output is not a table")
			local resultList: { any } = output["results"] :: any
			assert(typeof(resultList) == "table", "output -> results is not a table")
			okTask.output = {
				results = resultList,
			}
		else
			okTask.output = nil
		end

		return result.ok(okTask :: any)
	end
end

-- Class
local LuauExecutionUtil = {}

function LuauExecutionUtil.post<V>(
	universeId: number,
	placeId: number,
	versionNumber: number,
	content: string,
	timeout: number
): Future<Result<LuauExecutionTask<V>, Response<unknown>>>
	return future.from(function(): any
		return client
			.fromAPIKey()
			:post(
				CONSTANTS.OPEN_CLOUD_BASE_URL
					.. `/cloud/v2/universes/{universeId}/places/{placeId}/versions/{versionNumber}/luau-execution-session-tasks`
			)
			:body(reqwest.Body.fromJson({
				script = content,
				timeout = `{timeout}s`,
			}))
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(response)
				return result.ok(parseResponse(response))
			end, function(response)
				return result.err(response)
			end)
	end)
end

function LuauExecutionUtil.get<V>(
	okResponsePath: string
): Future<Result<LuauExecutionTask<V>, Response<unknown>>>
	return future.from(function(): any
		return client
			.fromAPIKey()
			:get(CONSTANTS.OPEN_CLOUD_BASE_URL .. `/cloud/v2/{okResponsePath}`)
			:header("Content-Type", "application/json")
			:build()
			:send()
			:await()
			:match(function(response)
				return result.ok(parseResponse(response))
			end, function(response)
				return result.err(response)
			end)
	end)
end

return LuauExecutionUtil
