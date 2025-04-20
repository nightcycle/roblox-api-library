--!strict
-- Services
-- Packages
-- Modules
local places = require("./places")
local messagingService = require("./messagingService")
local standardDatastores = require("./standardDatastores")
local orderedDatastores = require("./orderedDatastores")
-- Types
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
return {
	places = places,
	messagingService = messagingService,
	standardDatastores = standardDatastores,
	orderedDatastores = orderedDatastores,
}
