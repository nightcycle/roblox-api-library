--!strict
-- Services
-- Packages
local luneUtil = require("@pkg/@nightcycle/lune-util")
local err = require("@pkg/@nightcycle/error")
local option = require("@pkg/@nightcycle/option")
local reqwest = require("@pkg/@nightcycle/reqwest")
-- Modules
local src = require("../src")
-- Types
-- Constants
local UNIVERSE_ID = tonumber(luneUtil.Env["UNIVERSE_ID"]:expect(`UNIVERSE_ID is not set`))
assert(UNIVERSE_ID, "UNIVERSE_ID is not a number")
local DS_NAME = "test-ordered-datastore"
local DS_KEY = "test-key"
local DS_VALUE = 1
-- Variables
-- References
-- Private Functions
-- Class
