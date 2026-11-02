local qf = require("src.quickfunctions")

local function reclocker()
	if not Args then
		qf.err("arguments not found\n")
		return 1
	end

	local chosenclock = string.lower(tostring(Args.reclock))
	local pstate = io.open("/sys/kernel/debug/dri/0/pstate", "w")
	if not pstate then
		qf.err("couldn't open pstate file")
		os.exit(1)
	end
	local clock

	if chosenclock == "low" then
		qf.std("switching clock to low\n")
		clock = "07"
	elseif chosenclock == "mid" then
		qf.std("switching clock to mid\n")
		clock = "0a"
	elseif chosenclock == "high" then
		qf.std("switching clock to high\n")
		clock = "0f"
	end

	pstate:write(clock)
	pstate:close()
end

return reclocker
