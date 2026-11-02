local qf = require("src.quickfunctions")

local function reclocker()
	if not Args then
		qf.err("arguments not found\n")
		return 1
	end

	local chosenclock = string.lower(tostring(Args.reclock))
	local pstate = "/sys/kernel/debug/dri/0/pstate"
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
	os.execute("echo " .. clock .. " | tee " .. pstate)
end

return reclocker
