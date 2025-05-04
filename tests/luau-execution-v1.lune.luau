--!strict
-- Services
local fs = require("@lune/fs")
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")
local option = require("@pkg/@nightcycle/option")
-- Modules
local luauExecutionSessionTasks =
	require("../src/apis/cloud/v2/universes/places/luau-execution-session-tasks")
local luauExecutionSessionTasksVersions =
	require("../src/apis/cloud/v2/universes/places/luau-execution-session-tasks/versions")
local luauExecutionSessionTasksLogs =
	require("../src/apis/cloud/v2/universes/places/luau-execution-session-tasks/logs")
-- Types
-- Constants
local PLACE_ID = tonumber(luneUtil.Env["PLACE_ID"]:expect(`PLACE_ID is not set`))
local UNIVERSE_ID = tonumber(luneUtil.Env["UNIVERSE_ID"]:expect(`UNIVERSE_ID is not set`))
assert(PLACE_ID, "PLACE_ID is not a number")
assert(UNIVERSE_ID, "UNIVERSE_ID is not a number")
local VERSION_NUMBER = 1
local SCRIPT_PATH = "tests/data/luau-test.luau"
-- Variables
local content = fs.readFile(SCRIPT_PATH)
-- References
-- Private Functions
-- Class
local postData = luauExecutionSessionTasksVersions
	.post(UNIVERSE_ID, PLACE_ID, VERSION_NUMBER, content, option.none())
	:await()
	:unwrap()
	:unwrap()
print(`posted tasks: {err.displayAsJson(postData)}`)

while true do
	local pollData = luauExecutionSessionTasks.get(postData.path):await():unwrap():unwrap()
	if pollData.done then
		print(`completed task: {err.displayAsJson(pollData)}`)
		break
	else
		print(`task state: {pollData.state}, waiting...`)
		luneUtil.Task.wait(60 / 45)
	end
end

print("polls")
print(
	`posted tasks: {err.displayAsJson(
		luauExecutionSessionTasksLogs
			.get(postData.path, "STRUCTURED", option.none(), option.none())
			:await()
			:unwrap()
	)}`
)
