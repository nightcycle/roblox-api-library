--!strict
-- Services
local fs = require("@lune/fs")
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")
local option = require("@pkg/@nightcycle/option")
-- Modules
local assets = require("../src/apis/cloud/v1/assets")
local assetsOperations = require("../src/apis/cloud/v1/assets/operations")
local assetsAsset = require("../src/apis/cloud/v1/assets/asset")

-- Types
-- Constants
local GROUP_ID = tonumber(luneUtil.Env["GROUP_ID"]:expect(`GROUP_ID is not set`))
assert(GROUP_ID, "GROUP_ID is not a number")
local CREATE_ENABLED = false
local PNG_PATH = "tests/data/image.png"
-- local BMP_PATH = "tests/data/image.bmp"
-- local JPEG_PATH = "tests/data/image.jpg"
-- local TGA_PATH = "tests/data/image.tga"
local ASSET_ID = 135498858258730
-- Variables
-- References
-- Private Functions
-- Class
if CREATE_ENABLED then
	local createdAsset = assets
		.post("Decal", "image/png", "png test", "png test", "Group", GROUP_ID, fs.readFile(PNG_PATH))
		:await()
		:unwrap()
		:json()
		:unwrap()
	print(`saved png image: {err.displayAsJson(createdAsset)}`)
	local operationId = createdAsset["operationId"]
	while true do
		luneUtil.Task.wait(0.1)
		local operationData = assetsOperations.get(operationId):await():unwrap():json():unwrap()
		print(`operation: {err.displayAsJson(operationData)}`)
		if operationData["done"] then
			break
		end
	end
end

print(`getting asset: {err.displayAsJson(assetsAsset
	.get(2971874773, {
		description = true,
		displayName = true,
		icon = true,
		previews = true,
		facebookSocialLink = true,
		twitterSocialLink = true,
		youtubeSocialLink = true,
		twitchSocialLink = true,
		discordSocialLink = true,
		githubSocialLink = true,
		robloxSocialLink = true,
		guildedSocialLink = true,
		devForumSocialLink = true,
	})
	:await()
	:unwrap()
	:text()
	:unwrap())}`)

do
	local updateAsset = assetsAsset
		.patch(
			ASSET_ID,
			option.some(fs.readFile(PNG_PATH) :: string | buffer),
			option.none(),
			option.none(),
			option.none()
		)
		:await()
		:unwrap()
		:json()
		:unwrap()
	print(`saved png image: {err.displayAsJson(updateAsset)}`)
	local operationId = updateAsset["operationId"]
	while true do
		luneUtil.Task.wait(0.1)
		local operationData = assetsOperations.get(operationId):await():unwrap():json():unwrap()
		print(`operation: {err.displayAsJson(operationData)}`)
		if operationData["done"] then
			break
		end
	end
end
