--!strict
-- Services
-- Packages
-- Modules
local places = require("./places")
local messagingService = require("./messagingService")
local standardDatastores = require("./standardDatastores")
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
}
