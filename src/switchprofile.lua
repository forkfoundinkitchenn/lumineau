local qf = require("src.quickfunctions")
local detectDistro = require("src.detectdistro")
local paths = { "/var/cache/lumineau-cache", "/etc/modprobe.d/00-lumineau.conf", "/etc/udev/rules.d/00-lumineau.rules" }

local function rebuildInitramfs()
	local distro = detectDistro()
	local rebuild

	if distro == "void" or distro == "fedora" then
		rebuild = "dracut --force"
	elseif distro == "arch" then
		rebuild = "mkinitcpio -P"
	elseif distro == "debian" or distro == "ubuntu" or distro == "mint" then
		rebuild = "update-initramfs -u"
	else
		qf.err("unsupported\n")
		os.exit(1)
	end

	qf.verb(rebuild .. "\n")
end

local function switchProfile()
	if not Args then
		return 1
	end

	local chosenmode = string.lower(Args and Args.switch or "")

	if chosenmode == "integrated" or chosenmode == "i" then
		if qf.fileExists(paths[1]) and qf.fileExists(paths[2]) and qf.fileExists(paths[3]) and not Args.force then
			qf.err("hmm\n")
			os.exit(1)
		end

		qf.std("hi\n")
	elseif chosenmode == "hybrid" or chosenmode == "h" then
		if
			not qf.fileExists(paths[1])
			and not qf.fileExists(paths[2])
			and not qf.fileExists(paths[3])
			and not Args.force
		then
			qf.err("what\n")
			os.exit(1)
		end

		qf.std("bye\n")
	end

	rebuildInitramfs()
end

return switchProfile
