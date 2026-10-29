local qf = {}

function qf.std(string)
	io.stdout:write("[*] " .. string)
end

function qf.err(string)
	io.stderr:write("[-] " .. string)
end

function qf.verb(string)
	if Args and Args.verbose then
		io.stderr:write("[~] " .. string)
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
