local qf = {}

function qf.std(str)
	io.stdout:write("[*] " .. tostring(str))
end

function qf.err(str)
	io.stderr:write("[-] " .. tostring(str))
end

function qf.verb(str)
	if Args and Args.verbose then
		io.stderr:write("[~] " .. tostring(str))
	end
end

function qf.rootCheck()
	local euid = io.popen("id -u")
	if not euid then
		return
	end
	if euid:read("*n") ~= 0 then
		qf.err("you lack sufficient permissions at the moment\n")
		euid:close()
		os.exit(1)
	end

	euid:close()
end

function qf.fileExists(file)
	local f = io.open(file, "r")
	if f then
		f:close()
		return true
	else
		return false
	end
end

return qf
