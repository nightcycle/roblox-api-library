--!strict
-- Services
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")
local option = require("@pkg/@nightcycle/option")
-- Modules
local placeInstancesInstance = require("../src/apis/cloud/v2/universes/places/instances/Instance")
local placeInstancesInstanceOperation =
	require("../src/apis/cloud/v2/universes/places/instances/Instance/operation")
local placeInstancesListChildren = require("../src/apis/cloud/v2/universes/places/instances/listChildren")
local placeInstancesListChildrenOperation =
	require("../src/apis/cloud/v2/universes/places/instances/listChildren/operation")

-- Types
-- Constants
local PLACE_ID = tonumber(luneUtil.Env["PLACE_ID"]:expect(`PLACE_ID is not set`))
local UNIVERSE_ID = tonumber(luneUtil.Env["UNIVERSE_ID"]:expect(`UNIVERSE_ID is not set`))
assert(PLACE_ID, "PLACE_ID is not a number")
assert(UNIVERSE_ID, "UNIVERSE_ID is not a number")
-- Variables
-- References
-- Private Functions

-- Class

-- list
do
	local getOpData = placeInstancesListChildren
		.get(UNIVERSE_ID, PLACE_ID, option.none(), option.none(), option.none())
		:await()
		:unwrap()
	print(`started operation: {err.displayAsJson(getOpData)}`)

	while true do
		local res = placeInstancesListChildrenOperation.get(getOpData.path):await():unwrap()
		if res.done then
			print(`completed operation: {err.displayAsJson(res)}`)
			break
		else
			print(`waiting...`)
			luneUtil.Task.wait(60 / 45)
		end
	end
end

-- get
do
	local getOpData = placeInstancesInstance.get(UNIVERSE_ID, PLACE_ID, option.none()):await():unwrap()
	print(`started operation: {err.displayAsJson(getOpData)}`)

	while true do
		local res = placeInstancesInstanceOperation.get(getOpData.path):await():unwrap()
		if res.done then
			print(`completed operation: {err.displayAsJson(res)}`)
			break
		else
			print(`waiting...`)
			luneUtil.Task.wait(60 / 45)
		end
	end
end

-- update
do
	function getInstanceAsync(
		instId: option.Option<string>
	): option.Option<placeInstancesInstanceOperation.EngineInstance>
		local getOpData = placeInstancesInstance.get(UNIVERSE_ID, PLACE_ID, instId):await():unwrap()
		while true do
			local res = placeInstancesInstanceOperation.get(getOpData.path):await():unwrap()
			if res.done then
				return option.some(res.response.engineInstance)
			else
				luneUtil.Task.wait(60 / 45)
			end
		end
		return option.none()
	end
	function findFirstChildAsync(
		instId: option.Option<string>,
		name: string
	): option.Option<placeInstancesInstanceOperation.EngineInstance>
		local getOpData = placeInstancesListChildren
			.get(UNIVERSE_ID, PLACE_ID, instId, option.none(), option.none())
			:await()
			:unwrap()

		while true do
			local res = placeInstancesListChildrenOperation.get(getOpData.path):await():unwrap()
			if res.done then
				for k, v in pairs(res.response.instances) do
					if v.engineInstance.Name == name then
						return option.some(v.engineInstance)
					end
				end
				break
			else
				luneUtil.Task.wait(60 / 45)
			end
		end
		return option.none()
	end

	local rootInst = getInstanceAsync(option.none()):expect(`Root instance not found`)
	local workspaceInst =
		findFirstChildAsync(option.some(rootInst.Id), "Workspace"):expect(`"Workspace" not found`)
	local scriptInst =
		findFirstChildAsync(option.some(workspaceInst.Id), "Script"):expect(`"Script" not found`)
	if scriptInst then
		local patchData = placeInstancesInstance
			.patch(UNIVERSE_ID, PLACE_ID, option.some(scriptInst.Id), {
				Details = {
					Script = {
						Source = `print("{luneUtil.Net.generateGUID(false)}")`,
					},
				},
			})
			:await()
			:unwrap()

		while true do
			local res = placeInstancesInstanceOperation.get(patchData.path):await():unwrap()
			if res.done then
				print(`completed operation: {err.displayAsJson(res)}`)
				break
			else
				print(`waiting...`)
				luneUtil.Task.wait(60 / 45)
			end
		end
	end
end
