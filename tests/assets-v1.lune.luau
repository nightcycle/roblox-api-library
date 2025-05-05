--!strict
-- Services
local fs = require("@lune/fs")
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")
local option = require("@pkg/@nightcycle/option")
-- Modules
local assets = require("../src/apis/cloud/v1/assets")
local assetsOperations = assets.operations
local assetsAsset = assets.asset
local assetsAssetArchive = assetsAsset.archive
local assetsAssetRestore = assetsAsset.restore
local assetsAssetVersions = assetsAsset.versions

-- Types
-- Constants
local GROUP_ID = tonumber(luneUtil.Env["GROUP_ID"]:expect(`GROUP_ID is not set`))
assert(GROUP_ID, "GROUP_ID is not a number")
local TRY_PATCH_CONTENT = false
local PNG_PATH = "tests/data/image.png"
local PNG_ALT_PATH = "tests/data/image-alt.png"

-- Variables
-- References
-- Private Functions
-- Class
local createdAsset = assets
	.post("Decal", "image/png", "png test", "png test", "Group", GROUP_ID, fs.readFile(PNG_PATH))
	:await()
	:unwrap()

print(`saved png image: {err.displayAsJson(createdAsset)}`)
local assetId: option.Option<number> = option.none()
do
	local operationId = createdAsset["operationId"]
	while true do
		luneUtil.Task.wait(0.1)
		local operationData = assetsOperations.get(operationId):await():unwrap()
		print(`operation: {err.displayAsJson(operationData)}`)
		if operationData["done"] then
			assetId = option.from(tonumber(operationData["response"]["assetId"]))
			break
		end
	end
end

do
	local updateAsset = assetsAsset
		.patch(
			assetId:expect(`assetId is not set`),
			option.none(),
			option.some({
				icon = nil :: string?,
				displayName = "updated name" :: string?,
				description = "updated description" :: string?,
			}),
			option.none(),
			option.none()
		)
		:await()
		:unwrap()
	print(`updated asset info: {err.displayAsJson(updateAsset)}`)
	local operationId = updateAsset["operationId"]
	while true do
		luneUtil.Task.wait(0.1)
		local operationData = assetsOperations.get(operationId):await():unwrap()
		print(`operation: {err.displayAsJson(operationData)}`)
		if operationData["done"] then
			break
		end
	end
end

if TRY_PATCH_CONTENT then
	local updateAsset = assetsAsset
		.patch(
			assetId:expect(`assetId is not set`),
			option.some(fs.readFile(PNG_ALT_PATH) :: string | buffer),
			option.none(),
			option.none(),
			option.none()
		)
		:await()
		:unwrap()
	print(`update png image: {err.displayAsJson(updateAsset)}`)
	local operationId = updateAsset["operationId"]
	while true do
		luneUtil.Task.wait(0.1)
		local operationData = assetsOperations.get(operationId):await():unwrap()
		print(`operation: {err.displayAsJson(operationData)}`)
		if operationData["done"] then
			break
		end
	end
end

do
	local archivedAsset = assetsAssetArchive.post(assetId:expect(`assetId is not set`)):await():unwrap()
	print(`archived asset: {err.displayAsJson(archivedAsset)}`)
end

do
	local restoredAsset = assetsAssetRestore.post(assetId:expect(`assetId is not set`)):await():unwrap()
	print(`restoring asset: {err.displayAsJson(restoredAsset)}`)
end

do
	local assetVersions = assetsAssetVersions
		.get(assetId:expect(`assetId is not set`), option.none(), option.none())
		:await()
		:unwrap()
	print(`getting asset versions: {err.displayAsJson(assetVersions)}`)
end
