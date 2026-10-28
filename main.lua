#!/usr/bin/env lua5.3

--------------------------------
local argparse = require("argparse")
local parser = argparse("Lumineau")
parser:option("-s --switch", "switch modes [integrated|hybrid]")
parser:flag("-v --verbose", "enable verbose logging")
parser:flag("-i --info", "display info")
parser:flag(
	"-d --daemon",
	"automatic reclocking daemon for older gpus using nouveau, requires debugfs mounted to /sys/kernel/debug, unstable and may break your system. use at your own risk"
)
local args = parser:parse()

--------------------------------
local version = "0.0.1"
local pstate = "/home/juneforkazoid/Projects/lumineau/pstate"
local clients = "/home/juneforkazoid/Projects/lumineau/clients"

local function sprint(string)
	print("[*] " .. string)
end

local function eprint(string)
	print("[-] " .. string)
end

local function vprint(string)
	if args.verbose == true then
		print("[~] " .. string)
	end
end

function ChangeMode()
	local chosenmode = string.lower(args.switch)

	--WHY DONT CASE STATEMENTS EXIST!!!!!!!!!!!
	if chosenmode == "integrated" or chosenmode == "i" then
		sprint("run this command as integrated")
	elseif chosenmode == "hybrid" or chosenmode == "h" then
		sprint("run this command as hybrid")
	end

	sprint("general block of code here")
end

ChangeMode()
