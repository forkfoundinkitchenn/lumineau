#!/usr/bin/env lua5.3
--------------------------------
local argparse = require("libs.argparse")
local parser = argparse("Lumineau")
parser:option("-s --switch", "switch modes [integrated|hybrid|nouveau]")
parser:flag("-v --verbose", "enable verbose logging")
parser:flag("-i --info", "display info")
-- parser:flag(
-- 	"-d --daemon",
-- 	"automatic reclocking daemon for older gpus using nouveau, requires debugfs mounted to /sys/kernel/debug, unstable and may break your system. use at your own risk"
-- )
parser:flag("-f --force", "force a command")

Args = parser:parse()
--------------------------------
local qf = require("src.quickfunctions")
local paths = { "/var/cache/lumineau-cache", "/etc/modprobe.d/00-lumineau.conf", "/etc/udev/rules.d/00-lumineau.rules" }
local switchProfile = require("src.switchprofile")

local version = "v0.0.2"

if Args.info then
	qf.std("Lumineau " .. version .. "\n")
	for i = 1, #paths do
		if qf.fileExists(paths[i]) then
			qf.std("Existing files: " .. paths[i] .. "\n")
		end
	end
	local status = io.open(paths[1], "r")
	if status then
		qf.std("Current profile: " .. tostring(status:read()) .. "\n")
	end
end

if Args.switch then
	qf.rootCheck()
	switchProfile()
end
