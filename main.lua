#!/usr/bin/env lua5.3
--------------------------------
local argparse = require("argparse")
local parser = argparse("Lumineau")
parser:option("-s --switch", "switch modes [integrated|hybrid|nouveau]")
parser:flag("-v --verbose", "enable verbose logging")
parser:flag("-i --info", "display info")
parser:flag(
	"-d --daemon",
	"automatic reclocking daemon for older gpus using nouveau, requires debugfs mounted to /sys/kernel/debug, unstable and may break your system. use at your own risk"
)
parser:flag("-f --force", "force a command")

Args = parser:parse()
--------------------------------
local qf = require("src.quickfunctions")

local version = "v0.0.1"

if Args.info then
	qf.std("Lumieau " .. version .. "\n")
	qf.std("blah blah blah blah blah\n")
end

if Args.switch then
	local switchProfile = require("src.switchprofile")
	qf.rootCheck()
	switchProfile()
end
